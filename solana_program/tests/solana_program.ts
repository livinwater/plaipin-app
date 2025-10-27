import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { SolanaProgram } from "../target/types/solana_program";
import { expect } from "chai";

describe("solana_program", () => {
  // Configure the client to use the local cluster
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);

  const program = anchor.workspace.SolanaProgram as Program<SolanaProgram>;
  const owner = provider.wallet;

  // Derive the PDA for the companion account
  const [companionPda] = anchor.web3.PublicKey.findProgramAddressSync(
    [Buffer.from("companion"), owner.publicKey.toBuffer()],
    program.programId
  );

  describe("initialize_companion", () => {
    it("Initializes a companion with default values", async () => {
      const tx = await program.methods
        .initializeCompanion()
        .accounts({
          companion: companionPda,
          owner: owner.publicKey,
          systemProgram: anchor.web3.SystemProgram.programId,
        })
        .rpc();

      console.log("Initialize transaction signature:", tx);

      // Fetch the companion account
      const companion = await program.account.companion.fetch(companionPda);

      // Assertions
      expect(companion.owner.toString()).to.equal(owner.publicKey.toString());
      expect(companion.mood).to.equal(50); // Default mood
      expect(companion.interactionCount.toNumber()).to.equal(0);
      expect(companion.lastInteraction.toNumber()).to.be.greaterThan(0);
      expect(companion.bump).to.be.greaterThan(0);

      console.log("Companion initialized:");
      console.log("- Owner:", companion.owner.toString());
      console.log("- Mood:", companion.mood);
      console.log("- Interactions:", companion.interactionCount.toString());
      console.log("- Last Interaction:", new Date(companion.lastInteraction.toNumber() * 1000).toISOString());
    });

    it("Fails to initialize companion twice", async () => {
      try {
        await program.methods
          .initializeCompanion()
          .accounts({
            companion: companionPda,
            owner: owner.publicKey,
            systemProgram: anchor.web3.SystemProgram.programId,
          })
          .rpc();
        
        expect.fail("Should have thrown an error");
      } catch (error) {
        // Expected to fail because account already exists
        expect(error).to.exist;
      }
    });
  });

  describe("update_mood", () => {
    it("Updates companion mood successfully", async () => {
      const newMood = 75;

      const tx = await program.methods
        .updateMood(newMood)
        .accounts({
          companion: companionPda,
          owner: owner.publicKey,
        })
        .rpc();

      console.log("Update mood transaction signature:", tx);

      const companion = await program.account.companion.fetch(companionPda);
      
      expect(companion.mood).to.equal(newMood);
      console.log("Mood updated to:", companion.mood);
    });

    it("Updates mood to maximum (100)", async () => {
      const tx = await program.methods
        .updateMood(100)
        .accounts({
          companion: companionPda,
          owner: owner.publicKey,
        })
        .rpc();

      const companion = await program.account.companion.fetch(companionPda);
      expect(companion.mood).to.equal(100);
    });

    it("Updates mood to minimum (0)", async () => {
      const tx = await program.methods
        .updateMood(0)
        .accounts({
          companion: companionPda,
          owner: owner.publicKey,
        })
        .rpc();

      const companion = await program.account.companion.fetch(companionPda);
      expect(companion.mood).to.equal(0);
    });

    it("Fails to update mood above 100", async () => {
      try {
        await program.methods
          .updateMood(101)
          .accounts({
            companion: companionPda,
            owner: owner.publicKey,
          })
          .rpc();
        
        expect.fail("Should have thrown an error");
      } catch (error) {
        expect(error.toString()).to.include("InvalidMoodValue");
      }
    });

    it("Fails when non-owner tries to update mood", async () => {
      const unauthorizedUser = anchor.web3.Keypair.generate();
      
      try {
        await program.methods
          .updateMood(50)
          .accounts({
            companion: companionPda,
            owner: unauthorizedUser.publicKey,
          })
          .signers([unauthorizedUser])
          .rpc();
        
        expect.fail("Should have thrown an error");
      } catch (error) {
        // Should fail due to unauthorized owner
        expect(error).to.exist;
      }
    });
  });

  describe("record_interaction", () => {
    it("Records an interaction and increments count", async () => {
      const companionBefore = await program.account.companion.fetch(companionPda);
      const countBefore = companionBefore.interactionCount.toNumber();

      const tx = await program.methods
        .recordInteraction()
        .accounts({
          companion: companionPda,
          owner: owner.publicKey,
        })
        .rpc();

      console.log("Record interaction transaction signature:", tx);

      const companionAfter = await program.account.companion.fetch(companionPda);
      const countAfter = companionAfter.interactionCount.toNumber();

      expect(countAfter).to.equal(countBefore + 1);
      console.log("Interaction count:", countAfter);
    });

    it("Records multiple interactions", async () => {
      const companionBefore = await program.account.companion.fetch(companionPda);
      const countBefore = companionBefore.interactionCount.toNumber();

      // Record 5 interactions
      for (let i = 0; i < 5; i++) {
        await program.methods
          .recordInteraction()
          .accounts({
            companion: companionPda,
            owner: owner.publicKey,
          })
          .rpc();
      }

      const companionAfter = await program.account.companion.fetch(companionPda);
      const countAfter = companionAfter.interactionCount.toNumber();

      expect(countAfter).to.equal(countBefore + 5);
      console.log("Total interactions after batch:", countAfter);
    });

    it("Updates last_interaction timestamp", async () => {
      const companionBefore = await program.account.companion.fetch(companionPda);
      const timestampBefore = companionBefore.lastInteraction.toNumber();

      // Wait a bit to ensure timestamp difference
      await new Promise(resolve => setTimeout(resolve, 1000));

      await program.methods
        .recordInteraction()
        .accounts({
          companion: companionPda,
          owner: owner.publicKey,
        })
        .rpc();

      const companionAfter = await program.account.companion.fetch(companionPda);
      const timestampAfter = companionAfter.lastInteraction.toNumber();

      expect(timestampAfter).to.be.greaterThan(timestampBefore);
    });
  });

  describe("Integration tests", () => {
    it("Full workflow: initialize, update mood, record interactions", async () => {
      // Create a new user for clean test
      const newUser = anchor.web3.Keypair.generate();
      
      // Airdrop SOL to new user
      const signature = await provider.connection.requestAirdrop(
        newUser.publicKey,
        2 * anchor.web3.LAMPORTS_PER_SOL
      );
      await provider.connection.confirmTransaction(signature);

      // Derive PDA for new user
      const [newCompanionPda] = anchor.web3.PublicKey.findProgramAddressSync(
        [Buffer.from("companion"), newUser.publicKey.toBuffer()],
        program.programId
      );

      // 1. Initialize companion
      await program.methods
        .initializeCompanion()
        .accounts({
          companion: newCompanionPda,
          owner: newUser.publicKey,
          systemProgram: anchor.web3.SystemProgram.programId,
        })
        .signers([newUser])
        .rpc();

      let companion = await program.account.companion.fetch(newCompanionPda);
      expect(companion.mood).to.equal(50);
      expect(companion.interactionCount.toNumber()).to.equal(0);

      // 2. Update mood
      await program.methods
        .updateMood(80)
        .accounts({
          companion: newCompanionPda,
          owner: newUser.publicKey,
        })
        .signers([newUser])
        .rpc();

      companion = await program.account.companion.fetch(newCompanionPda);
      expect(companion.mood).to.equal(80);

      // 3. Record interactions
      await program.methods
        .recordInteraction()
        .accounts({
          companion: newCompanionPda,
          owner: newUser.publicKey,
        })
        .signers([newUser])
        .rpc();

      companion = await program.account.companion.fetch(newCompanionPda);
      expect(companion.interactionCount.toNumber()).to.equal(1);

      console.log("Full workflow completed successfully!");
      console.log("Final state:", {
        mood: companion.mood,
        interactions: companion.interactionCount.toString(),
        owner: companion.owner.toString(),
      });
    });
  });
});

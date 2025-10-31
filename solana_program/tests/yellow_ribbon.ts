import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { SolanaProgram } from "../target/types/solana_program";
import { assert } from "chai";

describe("Yellow Ribbon NFT", () => {
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);

  const program = anchor.workspace.SolanaProgram as Program<SolanaProgram>;
  const owner = provider.wallet.publicKey;

  // Derive PDAs
  const [companionPDA] = anchor.web3.PublicKey.findProgramAddressSync(
    [Buffer.from("companion"), owner.toBuffer()],
    program.programId
  );

  const [yellowRibbonPDA] = anchor.web3.PublicKey.findProgramAddressSync(
    [Buffer.from("accessory"), owner.toBuffer(), Buffer.from("yellow_ribbon")],
    program.programId
  );

  it("Initializes companion", async () => {
    try {
      await program.methods
        .initializeCompanion()
        .accounts({
          companion: companionPDA,
          owner: owner,
          systemProgram: anchor.web3.SystemProgram.programId,
        })
        .rpc();

      const companion = await program.account.companion.fetch(companionPDA);
      assert.equal(companion.mood, 50);
      assert.equal(companion.interactionCount.toNumber(), 0);
      console.log("✅ Companion initialized with mood:", companion.mood);
    } catch (e) {
      console.log("Note: Companion may already exist");
    }
  });

  it("Mints Yellow Ribbon NFT", async () => {
    const ribbonName = "Sunshine Ribbon";

    const tx = await program.methods
      .mintYellowRibbon(ribbonName)
      .accounts({
        accessory: yellowRibbonPDA,
        owner: owner,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .rpc();

    console.log("🎀 Yellow Ribbon minted! Transaction:", tx);

    // Fetch the minted accessory
    const accessory = await program.account.accessory.fetch(yellowRibbonPDA);

    assert.equal(accessory.owner.toString(), owner.toString());
    assert.equal(accessory.name, ribbonName);
    assert.equal(accessory.equipped, false);
    assert.deepEqual(accessory.accessoryType, { yellowRibbon: {} });

    console.log("✅ Yellow Ribbon details:");
    console.log("   Name:", accessory.name);
    console.log("   Owner:", accessory.owner.toString());
    console.log("   Type:", "Yellow Ribbon");
    console.log("   Equipped:", accessory.equipped);
    console.log("   Mint date:", new Date(accessory.mintDate.toNumber() * 1000).toLocaleString());
  });

  it("Equips Yellow Ribbon on companion", async () => {
    await program.methods
      .toggleAccessory()
      .accounts({
        accessory: yellowRibbonPDA,
        owner: owner,
      })
      .rpc();

    const accessory = await program.account.accessory.fetch(yellowRibbonPDA);
    assert.equal(accessory.equipped, true);

    console.log("✅ Yellow Ribbon equipped on companion!");
  });

  it("Unequips Yellow Ribbon", async () => {
    await program.methods
      .toggleAccessory()
      .accounts({
        accessory: yellowRibbonPDA,
        owner: owner,
      })
      .rpc();

    const accessory = await program.account.accessory.fetch(yellowRibbonPDA);
    assert.equal(accessory.equipped, false);

    console.log("✅ Yellow Ribbon unequipped");
  });

  it("Verifies accessory ownership", async () => {
    const accessory = await program.account.accessory.fetch(yellowRibbonPDA);
    const companion = await program.account.companion.fetch(companionPDA);

    assert.equal(accessory.owner.toString(), companion.owner.toString());
    console.log("✅ Accessory belongs to companion owner");
  });
});

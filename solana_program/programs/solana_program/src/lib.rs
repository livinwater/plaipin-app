use anchor_lang::prelude::*;

declare_id!("A7ofZzn2ucRg1qN1dZEHTHoJr4U9trwdyifiJACkwU8C");

#[program]
pub mod solana_program {
    use super::*;

    /// Initialize a new companion for the user
    pub fn initialize_companion(ctx: Context<InitializeCompanion>) -> Result<()> {
        let companion = &mut ctx.accounts.companion;
        let clock = Clock::get()?;

        companion.owner = ctx.accounts.owner.key();
        companion.mood = 50; // Start with neutral mood
        companion.interaction_count = 0;
        companion.last_interaction = clock.unix_timestamp;
        companion.bump = ctx.bumps.companion;

        msg!("Companion initialized for owner: {}", companion.owner);
        msg!("Starting mood: {}", companion.mood);

        Ok(())
    }

    /// Update the companion's mood
    pub fn update_mood(ctx: Context<UpdateCompanion>, new_mood: u8) -> Result<()> {
        require!(new_mood <= 100, CompanionError::InvalidMoodValue);

        let companion = &mut ctx.accounts.companion;
        let clock = Clock::get()?;

        companion.mood = new_mood;
        companion.last_interaction = clock.unix_timestamp;

        msg!("Mood updated to: {}", new_mood);

        Ok(())
    }

    /// Record an interaction with the companion
    pub fn record_interaction(ctx: Context<UpdateCompanion>) -> Result<()> {
        let companion = &mut ctx.accounts.companion;
        let clock = Clock::get()?;

        companion.interaction_count = companion.interaction_count
            .checked_add(1)
            .ok_or(CompanionError::InteractionOverflow)?;
        companion.last_interaction = clock.unix_timestamp;

        msg!("Interaction recorded. Total: {}", companion.interaction_count);

        Ok(())
    }

    /// Mint a Yellow Ribbon accessory NFT
    /// Payment should be handled separately by the mobile app before calling this
    /// Uses timestamp as seed to allow multiple Yellow Ribbons per user
    pub fn mint_yellow_ribbon(ctx: Context<MintAccessory>, name: String, seed: u64) -> Result<()> {
        let accessory = &mut ctx.accounts.accessory;
        let clock = Clock::get()?;

        accessory.owner = ctx.accounts.owner.key();
        accessory.accessory_type = AccessoryType::YellowRibbon;
        accessory.name = name;
        accessory.mint_date = clock.unix_timestamp;
        accessory.equipped = false;
        accessory.seed = seed;
        accessory.bump = ctx.bumps.accessory;

        msg!("🎀 Yellow Ribbon minted for owner: {}", accessory.owner);
        msg!("Name: {}", accessory.name);
        msg!("Seed: {}", seed);

        Ok(())
    }

    /// Equip or unequip an accessory on the companion
    pub fn toggle_accessory(ctx: Context<ToggleAccessory>, seed: u64) -> Result<()> {
        let accessory = &mut ctx.accounts.accessory;
        accessory.equipped = !accessory.equipped;

        let status = if accessory.equipped { "equipped" } else { "unequipped" };
        msg!("Yellow Ribbon (seed: {}) {} for companion", seed, status);

        Ok(())
    }
}

// Account Structures

#[derive(Accounts)]
pub struct InitializeCompanion<'info> {
    #[account(
        init,
        payer = owner,
        space = 8 + Companion::INIT_SPACE,
        seeds = [b"companion", owner.key().as_ref()],
        bump
    )]
    pub companion: Account<'info, Companion>,

    #[account(mut)]
    pub owner: Signer<'info>,

    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct UpdateCompanion<'info> {
    #[account(
        mut,
        seeds = [b"companion", owner.key().as_ref()],
        bump = companion.bump,
        has_one = owner @ CompanionError::UnauthorizedOwner
    )]
    pub companion: Account<'info, Companion>,

    pub owner: Signer<'info>,
}

#[derive(Accounts)]
#[instruction(name: String, seed: u64)]
pub struct MintAccessory<'info> {
    #[account(
        init,
        payer = owner,
        space = 8 + Accessory::INIT_SPACE,
        seeds = [b"accessory", owner.key().as_ref(), seed.to_le_bytes().as_ref()],
        bump
    )]
    pub accessory: Account<'info, Accessory>,

    #[account(mut)]
    pub owner: Signer<'info>,

    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
#[instruction(seed: u64)]
pub struct ToggleAccessory<'info> {
    #[account(
        mut,
        seeds = [b"accessory", owner.key().as_ref(), seed.to_le_bytes().as_ref()],
        bump = accessory.bump,
        has_one = owner @ CompanionError::UnauthorizedOwner
    )]
    pub accessory: Account<'info, Accessory>,

    pub owner: Signer<'info>,
}

// Data Structures

#[account]
#[derive(InitSpace)]
pub struct Companion {
    pub owner: Pubkey,           // 32 bytes
    pub mood: u8,                // 1 byte (0-100)
    pub interaction_count: u64,  // 8 bytes
    pub last_interaction: i64,   // 8 bytes (Unix timestamp)
    pub bump: u8,                // 1 byte (PDA bump)
}

#[account]
#[derive(InitSpace)]
pub struct Accessory {
    pub owner: Pubkey,           // 32 bytes
    pub accessory_type: AccessoryType, // 1 byte (enum)
    #[max_len(50)]
    pub name: String,            // 4 + 50 bytes
    pub mint_date: i64,          // 8 bytes (Unix timestamp)
    pub equipped: bool,          // 1 byte
    pub seed: u64,               // 8 bytes (unique seed for multiple mints)
    pub bump: u8,                // 1 byte (PDA bump)
}

#[derive(AnchorSerialize, AnchorDeserialize, Clone, PartialEq, Eq, InitSpace)]
pub enum AccessoryType {
    YellowRibbon,
    // Can add more accessories later:
    // BlueHat,
    // PinkBow,
    // Glasses,
}

// Custom Errors

#[error_code]
pub enum CompanionError {
    #[msg("Mood value must be between 0 and 100")]
    InvalidMoodValue,
    
    #[msg("Interaction count overflow")]
    InteractionOverflow,
    
    #[msg("Only the companion owner can perform this action")]
    UnauthorizedOwner,
}

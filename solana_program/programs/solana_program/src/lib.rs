use anchor_lang::prelude::*;

declare_id!("6HD4mpueEPSMWMFCVraYnKC4Kyg1KJyqZLMHPJEJgh63");

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

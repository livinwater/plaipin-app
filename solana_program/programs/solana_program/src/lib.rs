use anchor_lang::prelude::*;

declare_id!("6HD4mpueEPSMWMFCVraYnKC4Kyg1KJyqZLMHPJEJgh63");

#[program]
pub mod solana_program {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        Ok(())
    }
}

#[derive(Accounts)]
pub struct Initialize {}

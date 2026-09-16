/*
 * Rates for shinies and other random properties are defined in this file.
 * CHANCE is defined as x/65536
 * RATE is defined as 1/x
 */

// #region Encounterable properties

/** `64/65536 -> 1/1024` */
export const BASE_SHINY_CHANCE = 8192;

/** `1 / 256` */
export const BASE_HIDDEN_ABILITY_RATE = 8192;

// #endregion Encounterable properties

// #region Egg properties

// Threshold x at which a gacha egg is determined to be a certain tier
// Specifically, the tier is determined by the highest threshold a random value between 0-255 meets or exceeds
// Legendary Up Gacha raises these thresholds by 1, thereby giving Legendary eggs 2/256 chance
export const GACHA_DEFAULT_COMMON_EGG_THRESHOLD = 192; // Default 64/256 chance
export const GACHA_DEFAULT_RARE_EGG_THRESHOLD = 128; // Default 64/256 chance
export const GACHA_DEFAULT_EPIC_EGG_THRESHOLD = 64; // Default 64/256 chance, leaving Legendary as 64/256 chance
export const GACHA_LEGENDARY_UP_THRESHOLD_OFFSET = 1; // The offset to threshold for Legendary Up gacha eggs. +x/256 Legendary Egg chance, -x/256 Common Egg chance

// The number of eggs without finding a certain tier egg it takes for egg pity to kick in and that tier to be forced
// These numbers are roughly the 80% mark. That is, 80% of the time you'll get an egg before this gets triggered.
export const EGG_PITY_LEGENDARY_THRESHOLD = 11;
export const EGG_PITY_EPIC_THRESHOLD = 10;
export const EGG_PITY_RARE_THRESHOLD = 9;

// Waves to hatch an egg of a given tier
export const HATCH_WAVES_COMMON_EGG = 5;
export const HATCH_WAVES_RARE_EGG = 6;
export const HATCH_WAVES_EPIC_EGG = 7;
export const HATCH_WAVES_LEGENDARY_EGG = 8;
export const HATCH_WAVES_MANAPHY_EGG = 8;

// Rates for specific random properties in 1/x
export const GACHA_DEFAULT_SHINY_RATE = 8;
export const GACHA_SHINY_UP_SHINY_RATE = 4;
export const SAME_SPECIES_EGG_SHINY_RATE = 4;
export const SAME_SPECIES_EGG_HA_RATE = 8;
export const MANAPHY_EGG_MANAPHY_RATE = 8;
export const GACHA_EGG_HA_RATE = 8;

// Odds are 1/x
// [COMMON, RARE, EPIC/MANAPHY, LEGEND]
export const RARE_EGGMOVE_RATES: readonly number[] = [4, 4, 4, 2];
export const BOOSTED_RARE_EGGMOVE_RATES: readonly number[] = [4, 4, 4, 2];

// #endregion Egg properties

// #region Variant properties

// The chance x/10 of a shiny being a variant, then of being specifically an epic variant
export const SHINY_VARIANT_CHANCE = 7;
export const SHINY_EPIC_CHANCE = 5;

// The catch rate bonus for shiny mons, introduced in Z-A. Can be boosted in events.
export const SHINY_CATCH_RATE_MULTIPLIER = 8;

// #endregion Variant properties

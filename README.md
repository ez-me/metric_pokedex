# Metric Pokédex

Mod for [gen1recomp](https://gen1re.com/)

Displays Pokédex height and weight using metric units.

## Conversion rules

### Generation 1/2

The existing mod path converts the game's stored imperial values:

- height: feet/inches -> metres
- weight: tenths of pounds -> kilograms
- rounded to one decimal place

The original game values are used; later corrected Pokédex values are not substituted.

### Generation 3

Gen 3 source Pokédex data is already metric:

- `height` is decimetres
- `weight` is hectograms

The mod adds the supported `heightM` and `weightKg` fields to the Gen 3 Pokémon content records. The existing Gen 3 Pokédex renderer then displays those values.

For example, Emerald Torchic:

- source height: `4` -> `0.4 m`
- source weight: `25` -> `2.5 kg`

## Labels

The original `HT.` and `WT.` labels are retained.

No Pokémon species list is hard-coded, so additional species present in the merged Pokémon registry are handled automatically when they use the Gen 3 measurement schema.


## AI Usage

This was videcoded using ChatGPT 5.6 Luna

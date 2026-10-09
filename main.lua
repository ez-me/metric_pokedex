-- Metric Pokedex
-- Converts Pokédex measurements to metric while preserving HT. / WT. labels.
-- Supports Gen 1/2 imperial measurements and Gen 3 native measurements.

local INCH_TO_M = 0.0254
local LB_TO_KG = 0.45359237

local function round1(x)
   return math.floor(x * 10 + 0.5) / 10
end

local function metricFromImperial(feet, inches, weightTenthsLb)
   if type(feet) ~= "number" or type(inches) ~= "number"
      or type(weightTenthsLb) ~= "number" then
      return nil, nil
   end

   local totalInches = feet * 12 + inches
   return round1(totalInches * INCH_TO_M),
      round1((weightTenthsLb / 10) * LB_TO_KG)
end

local function patchGen1(mod)
   local pokemon = mod.content and mod.content.pokemon
   if not pokemon or not pokemon.each or not pokemon.patch then return end

   for id, def in pokemon:each() do
      local e = def and def.dexEntry
      if e and type(e.heightFt) == "number"
         and type(e.heightIn) == "number"
         and type(e.weight) == "number"
         and e.heightM == nil then
         local heightM, weightKg = metricFromImperial(
            e.heightFt, e.heightIn, e.weight)
         if heightM ~= nil then
            pokemon:patch(id, {
               dexEntry = {
                  heightM = heightM,
                  weightKg = weightKg,
               },
            })
         end
      end
   end
end

local function patchGen3(mod)
   local pokemon = mod.content and mod.content.pokemon
   if not pokemon or not pokemon.each or not pokemon.patch then return end

   local converted = 0

   for id, def in pokemon:each() do
      local dex = def and def.dexEntry

      -- Gen 3 stores height in decimeters and weight in hectograms.
      -- Convert both to metric presentation fields used by the renderer.
      if type(dex) == "table"
         and type(dex.height) == "number"
         and type(dex.weight) == "number"
         and dex.heightM == nil
         and dex.weightKg == nil then

         pokemon:patch(id, {
            dexEntry = {
               heightM = dex.height / 10,
               weightKg = dex.weight / 10,
            },
         })

         converted = converted + 1
      end
   end

   if mod.log and mod.log.info then
      mod.log:info(
         "metric_pokedex: added metric values to %d Gen 3 species",
         converted
      )
   end
end

local function installLabelFix()
   local ok, Font = pcall(require, "src.render.Font")
   if not ok or type(Font) ~= "table" or type(Font.draw) ~= "function" then
      return
   end
   if Font.__metricPokedexLabelsInstalled then return end
   Font.__metricPokedexLabelsInstalled = true

   local oldDraw = Font.draw
   Font.draw = function(text, x, y, ...)
      if type(text) == "string" then
         text = text:gsub("^GR%. ", "HT. ")
         text = text:gsub("^GEW%. ", "WT. ")
      end
      return oldDraw(text, x, y, ...)
   end
end

return function(mod)
   patchGen1(mod)
   patchGen3(mod)
   installLabelFix()
end

#packmode normal
#priority 0

import crafttweaker.item.IItemStack;
import crafttweaker.item.IIngredient;
import crafttweaker.oredict.IOreDictEntry;
import scripts.hds_main.utils.modloader.isInvalid;

//something that recipeutils can't do or just remove
val removeByOutput as IItemStack[] = [
    <thaumadditions:brass_plated_silverwood>,
    <bloodmagic:blood_rune>,
    <bloodmagic:altar>
];

if(!isInvalid) {
    for item in removeByOutput {
        recipes.remove(item);
    }
}

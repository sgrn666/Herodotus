#packmode normal
#priority 2
import scripts.hds_main.utils.modloader.isInvalid;

if (!isInvalid) {
    <minecraft:obsidian>.asBlock().definition.resistance = 8.0f;
    <minecraft:iron_pickaxe>.maxDamage = 300;
    <astralsorcery:blockcustomore>.asBlock().definition.setHarvestLevel("pickaxe", 1);
}

#packmode normal
#priority -1

import crafttweaker.data.IData;
import crafttweaker.world.IWorld;
import crafttweaker.world.IBlockPos;
import crafttweaker.world.IFacing;
import crafttweaker.player.IPlayer;
import crafttweaker.event.EntityLivingDamageEvent;
import crafttweaker.event.PlayerTickEvent;
import crafttweaker.event.PlayerCloneEvent;
import crafttweaker.entity.IEntityDefinition;
import crafttweaker.entity.AttributeInstance;
import crafttweaker.entity.AttributeModifier;
import crafttweaker.util.IRandom;
import mods.hdsutils.ITaint;
import mods.ctutils.utils.Math;
import scripts.hds_main.utils.modloader.isInvalid;
import scripts.grassUtils.EventUtils;

static priEntities as IEntityDefinition[] = [
    <entity:srparasites:pri_longarms>,
    <entity:srparasites:pri_manducater>,
    <entity:srparasites:pri_reeker>,
    <entity:srparasites:pri_yelloweye>,
    <entity:srparasites:pri_summoner>,
    <entity:srparasites:pri_bolster>,
    <entity:srparasites:pri_arachnida>
];

static taintUUID1 as string = "a6a68061-8cc9-48d0-8b69-54e7ee383ed8";
static taintUUID2 as string = "bdb6f5a0-c20a-4d70-96d7-0b2a74331b04";

function spawnEntityNearby(entity as IEntityDefinition, world as IWorld, pos as IBlockPos, random as IRandom) {
    val xOffset as int = random.nextInt(11) - 5;
    val zOffset as int = random.nextInt(11) - 5;
    var pos1 as IBlockPos = EventUtils.getOffset(pos, xOffset, 0, zOffset);
    while (pos1.y < 256 && world.getBlockState(pos1) != <blockstate:minecraft:air>) {
        pos1 = pos1.getOffset(IFacing.up(), 1);
    }
    entity.spawnEntity(world, pos1);
} 

if (!isInvalid) {
    events.onEntityLivingDamage(function(event as EntityLivingDamageEvent) {
        if (event.entityLivingBase instanceof IPlayer) {
            val player as IPlayer = event.entityLivingBase;
            val pos as IBlockPos = player.position;
            val world as IWorld = player.world;
            val taint as ITaint = player.taint;
            if (taint.moreThanScale(0.95f)) {
                player.attackEntityFrom(<damageSource:GENERIC>, 1145141919810.0f);
                event.cancel();
            } else if (taint.moreThanScale(0.85f)) {
                event.amount *= 3.45f;
            } else if (taint.moreThanScale(0.55f)) {
                event.amount *= 2.5f;
                if (event.amount >= 20.0f && !world.remote) {
                    val random as IRandom = world.random;
                    spawnEntityNearby(priEntities[random.nextInt(priEntities.length)], world, pos, random);
                }
            } else if (taint.moreThanScale(0.3f)) {
                event.amount *= 1.5f;
            }
            if (taint.moreThanScale(0.4f) && !world.remote) {
                world.addFlux(pos, taint.scale / 50);
            }
        }
    });

    events.onPlayerTick(function(event as PlayerTickEvent) {
        val player as IPlayer = event.player;
        if (player.world.remote) 
            return;
        val random as IRandom = player.world.random;
        val maxHealth as AttributeInstance = player.getAttribute("generic.maxHealth");
        val taint as ITaint = player.taint;
        if (taint.moreThanScale(0.5f)) {
            maxHealth.applyModifier(AttributeModifier.createModifier("Taint50", player.maxHealth, 0, taintUUID1));
        }
        if (taint.moreThanScale(0.4f)) {
            var temp as int = (taint.scale * 100.0f) as int;
            while (temp % 5 != 0) {
                temp -= 1;
            }
            val lastAddingMaxHealthTaint as IData = player.data.LastAddingMaxHealthTaint;
            if (isNull(lastAddingMaxHealthTaint) || Math.abs(lastAddingMaxHealthTaint.asFloat() - taint.scale) >= 5.0f) {
                player.update({LastAddMaxHealthTaint: temp});
                maxHealth.removeModifier(taintUUID2);
                maxHealth.applyModifier(AttributeModifier.createModifier("TaintDynamic", maxHealth.baseValue * taint.scale, 0, taintUUID2));
            }
        }
        if (taint.moreThanScale(0.65f) && random.nextInt(500000) == 233333) {
            player.addPotionEffect(<potion:hdsutils:starvation>.makePotionEffect(1200, 1));
        }
    });

    events.onPlayerClone(function(event as PlayerCloneEvent) {
        val originalModifier = event.originalPlayer.getAttribute("generic.maxHealth").getModifier(taintUUID1);
        if (!isNull(originalModifier)) {
            val amount as double = originalModifier.amount;
            event.player.getAttribute("generic.maxHealth").applyModifier(AttributeModifier.createModifier("Taint50", amount, 0, taintUUID1));
        }
    });
}
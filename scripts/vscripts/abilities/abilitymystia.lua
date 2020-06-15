if AbilityMystia == nil then
  AbilityMystia = class({})
end

--particles/econ/items/wisp/wisp_guardian_explosion_ti7.vpcf
function Mystia01OnSpellStart(keys)

    local duration = keys.ability:GetSpecialValueFor("duration")
    local caster = EntIndexToHScript(keys.caster_entindex)
    local targetPoint = caster:GetOrigin()
    local distance = keys.range
    local agi = caster:GetAgility()
    caster:EmitSound("Voice_Thdots_Mystia.AbilityMystia01")
    local targets = FindUnitsInRadius(
             caster:GetTeam(),
             targetPoint,
             self,
             distance,
             DOTA_UNIT_TARGET_TEAM_ENEMY,
             keys.ability:GetAbilityTargetType(),
             0,
             0,
             false)

    for _,v in pairs(targets) do
        local DamageTable = {
                           ability = keys.ability,
                           victim = v, 
                           attacker = caster, 
                           damage = keys.damage + agi * 1.5 , 
                           damage_type = keys.ability:GetAbilityDamageType()
                  }
       ApplyDamage(DamageTable)
       if GameRules:IsDaytime() then
        keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_mystia01", {Duration = duration + FindTelentValue(caster,"special_bonus_unique_mystia_1")})
       else
        keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_mystia02", {Duration = duration + FindTelentValue(caster,"special_bonus_unique_mystia_1")})
       end
    end
end

--particles/versus/versus_explosion_burst_sphere.vpcf
function Mystia02OnSpellStart(keys)
    --增加攻速20 30 40 50，移动速度增加7% 14% 21% 30%
    local duration = keys.ability:GetSpecialValueFor("duration")
    local caster = EntIndexToHScript(keys.caster_entindex)
    -- local flag = FindTelentValue(caster,"special_bonus_unique_luna_5")
    local flag2 = FindTelentValue(caster,"special_bonus_unique_night_stalker_2") 
    local targetPoint = caster:GetOrigin()
    if RollPercentage(80) then
      caster:EmitSound("Voice_Thdots_Mystia.AbilityMystia02")
    end

    keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_mystia02_area", {Duration = duration})

    -- if flag~=0 then
    --    keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_mystia02_area_2", {Duration = duration})
    -- end
    if flag2~=0 then
       keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_mystia02_area_1", {Duration = duration})
    end

end

--particles/units/heroes/hero_void_spirit/travel_strike/void_spirit_travel_strike_path_core.vpcf
--particles/dev/library/base_item_attachment_magic.vpcf
--particles/econ/items/jakiro/jakiro_ti7_immortal_head/jakiro_ti7_immortal_head_ice_path_embers.vpcf
function mystia03OnExecuted(keys)
  if keys.event_ability:IsItem() then return end
  local target = keys.unit
  local targetPoint = target:GetOrigin()
  local ability = keys.ability
  local CurrentActiveAbility = target:GetCurrentActiveAbility()
  local mana = ability:GetLevelSpecialValueFor("restoredmana", ability:GetLevel() - 1 )
  local chance = ability:GetLevelSpecialValueFor("chance", ability:GetLevel() - 1 )
  if CurrentActiveAbility:GetCooldown(CurrentActiveAbility:GetLevel()) > 1  then
    if RollPercentage(chance) then
      target:GiveMana(mana)
      local effectIndex=  ParticleManager:CreateParticle("particles/thd2/heroes/mystia/mystia03.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, target)
          ParticleManager:DestroyParticleSystem(effectIndex,false)
    end
  end
end


--particles/units/heroes/hero_siren/naga_siren_siren_song_cast.vpcf
function Mystia04OnSpellStart(keys)

    local level = keys.ability:GetLevel() - 1
    local caster = EntIndexToHScript(keys.caster_entindex)
    local targetPoint = caster:GetOrigin()
    local distance = keys.range
    local targetPoint = caster:GetOrigin()
    local myteam = caster:GetTeam()
    local duration = keys.ability:GetSpecialValueFor("duration")
    caster:EmitSound("Voice_Thdots_Mystia.AbilityMystia04")
    
    local forts = Entities:FindAllByClassnameWithin("npc_dota_fort",caster:GetOrigin(), distance) 
    local wards = Entities:FindAllByClassnameWithin("npc_dota_ward_base",caster:GetOrigin(), distance) 
    local buildings = Entities:FindAllByClassnameWithin("npc_dota_building",caster:GetOrigin(), distance) 
    local watch_towers = Entities:FindAllByClassnameWithin("npc_dota_watch_tower",caster:GetOrigin(), distance) 
    local towers = Entities:FindAllByClassnameWithin("npc_dota_tower",caster:GetOrigin(), distance) 
    local barracks = Entities:FindAllByClassnameWithin("npc_dota_barracks",caster:GetOrigin(), distance)

    for _,v in pairs(wards) do
      if v:GetTeam() ~= myteam then
      keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_mystia04_toother", {Duration = duration})
        end
    end
        for _,v in pairs(buildings) do
      if v:GetTeam() ~= myteam then
      keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_mystia04_toother", {Duration = duration})
        end
    end
        for _,v in pairs(towers) do
      if v:GetTeam() ~= myteam then
      keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_mystia04_toother", {Duration = duration})
        end
    end
        for _,v in pairs(watch_towers) do
      if v:GetTeam() ~= myteam then
      keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_mystia04_toother", {Duration = duration})
        end
    end
        for _,v in pairs(forts) do
      if v:GetTeam() ~= myteam then
      keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_mystia04_toother", {Duration = duration})
        end
    end
        for _,v in pairs(barracks) do
      if v:GetTeam() ~= myteam then
      keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_mystia04_toother", {Duration = duration})
        end
    end



    local targets = FindUnitsInRadius(
             caster:GetTeam(),
             targetPoint,
             self,
             distance,
             DOTA_UNIT_TARGET_TEAM_ENEMY,
             keys.ability:GetAbilityTargetType() ,
             0,
             0,
             false)


    for _,v in pairs(targets) do
     --加个伤害
        local DamageTable = {
                           ability = keys.ability,
                           victim = v, 
                           attacker = caster, 
                           damage = keys.damage ,
                           damage_type = keys.ability:GetAbilityDamageType()
                  }
       ApplyDamage(DamageTable)
       keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_mystia04_1", {Duration = duration})


    --对于英雄单位
    if v:IsHero() then
    keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_mystia04_tohero", {Duration = duration})
    local effectIndexscreen = ParticleManager:CreateParticleForPlayer("particles/thd2/heroes/mystia/mystia04_screen.vpcf", PATTACH_CUSTOMORIGIN, v , v:GetOwner())
    local effectIndexscreen2 = ParticleManager:CreateParticleForPlayer("particles/generic_gameplay/screen_death_indicator_b.vpcf", PATTACH_CUSTOMORIGIN, v , v:GetOwner())
    ParticleManager:DestroyParticleSystemTime(effectIndexscreen,duration)
    ParticleManager:DestroyParticleSystemTime(effectIndexscreen2,duration)
    end
     --对于其他敌方单位
     if not v:IsHero() then
        keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_mystia04_toother", {Duration = duration})
     end
  end
end

function mystiaExOnSpellStart( keys )
  local caster = keys.caster
  keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_mystiaEx_fly", {Duration = 4 + FindTelentValue(caster,"special_bonus_unique_luna_5")})
end

--弱肉强食天生被动
function mystiaExOnAttackLanded(keys)
  local target = keys.target
  local rate = keys.ability:GetSpecialValueFor("rate")
  local base = keys.ability:GetSpecialValueFor("base")
  
  if target:IsHero() or target:IsNeutralUnitType() then

  local caster = EntIndexToHScript(keys.caster_entindex)
  local caster_level = caster:GetLevel()
  local target_level = target:GetLevel()
  
  if target:IsAncient() then 
    target_level = target_level * 2
  end
      --当小碎骨等级比敌人高的时候，造成额外的魔法伤害
      if caster_level > target_level then 
        local damage = base + (caster_level - target_level) * rate
        --10级天赋
        if FindTelentValue(caster,"special_bonus_unique_night_stalker") ~= 0 then
           damage = damage * 2
        end
        
        local damage_table = {
             ability = keys.ability,
             victim = target, 
             attacker = caster, 
             damage = damage, 
             damage_type = keys.ability:GetAbilityDamageType()
        }

        UnitDamageTarget(damage_table) 
      end
    end
end

--Ex高空视野
function mystiainnatevision(keys)
  local caster = keys.caster
    AddFOWViewer(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster:GetCurrentVisionRange(), 0.051, false)
end
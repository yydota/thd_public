--8/18/2020 Update
ability_thdots_reisen_2_01=class({})

function ability_thdots_reisen_2_01:IsHiddenWhenStolen()        return false end
function ability_thdots_reisen_2_01:IsRefreshable()             return true end
function ability_thdots_reisen_2_01:IsStealable()           return true end

--技能1 触发事件

--修改施法距离：万宝槌
function ability_thdots_reisen_2_01:GetCastRange(location,target)
    if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
        return self.BaseClass.GetCastRange(self,location,target)+ self:GetSpecialValueFor("scepter_increase")
    else
        return self.BaseClass.GetCastRange(self,location,target)
    end
end

--技能使用触发
function ability_thdots_reisen_2_01:OnSpellStart()
    if not IsServer() then return end
    --基础信息
    local caster=self:GetCaster()
    local target=self:GetCursorTarget()
    local buff_duration=self:GetSpecialValueFor("default_buff_duration")
    --print(buff_duration)
    --print(self:GetSpecialValueFor("reduce_multiplier"))

    --对自己使用判定
    self.cast_self=false
    --消除音效保存
    self.owner=caster

    --确保刷新技能不影响特效
    if caster:HasModifier("modifier_ability_thdots_reisen2_01_buff") then
        caster:RemoveModifierByName("modifier_ability_thdots_reisen2_01_buff")
    end

    --加入modifier
    --血魔buff不需要了 以后修改技能或许可以使用
    if target==caster then
        --caster:AddNewModifier(caster, self, "modifier_bloodseeker_thirst", {duration = buff_duration*self:GetSpecialValueFor("reduce_multiplier")})
        caster:AddNewModifier(caster,self,"modifier_ability_thdots_reisen2_01_buff",{duration=buff_duration*self:GetSpecialValueFor("reduce_multiplier")})
        self.cast_self=true
    elseif target:GetTeam()==caster:GetTeam() then
        --caster:AddNewModifier(caster, self, "modifier_bloodseeker_thirst", {duration = buff_duration})
        caster:AddNewModifier(caster,self,"modifier_ability_thdots_reisen2_01_buff",{duration=buff_duration})
        caster:MoveToNPC(target)
    else
        --caster:AddNewModifier(caster, self, "modifier_bloodseeker_thirst", {duration = buff_duration})
        caster:AddNewModifier(caster,self,"modifier_ability_thdots_reisen2_01_buff",{duration=buff_duration})
        caster:MoveToTargetToAttack(target)
        target:AddNewModifier(caster, self, "modifier_mark_target", {duration = buff_duration})
    end

    --粒子，声音
    local particle="particles/econ/items/windrunner/windrunner_cape_sparrowhawk/windrunner_windrun_sparrowhawk.vpcf"
    --保存粒子
    self.particle=ParticleManager:CreateParticle(particle, PATTACH_ROOTBONE_FOLLOW, caster)
    EmitSoundOn("Ability.Windrun",caster)
    
end

--技能1 modifiers

--modifier 名字：标记敌人

modifier_mark_target=class({})
LinkLuaModifier("modifier_mark_target","scripts/vscripts/abilities/abilityreisen2.lua",LUA_MODIFIER_MOTION_NONE)

--modifier 基础判定
function modifier_mark_target:IsHidden()        return false end
function modifier_mark_target:IsPurgable()      return false end
function modifier_mark_target:RemoveOnDeath()   return true end
function modifier_mark_target:IsDebuff()        return true end

--modifier 修改列表
function modifier_mark_target:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end
--modifier 触发事件
function modifier_mark_target:OnAttackLanded(keys)
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = keys.target
    local attacker = keys.attacker
    local hability = self:GetAbility()

    --如果攻击者是自己
    if attacker==caster then
        --敌人增加减速buff
        target:AddNewModifier(caster,hability,"modifier_ability_thdots_reisen2_01_debuff",
        {duration=hability:GetSpecialValueFor("slow_duration")})

        --消除加速，消除标记
        --caster:RemoveModifierByName("modifier_bloodseeker_thirst")
        caster:RemoveModifierByName("modifier_ability_thdots_reisen2_01_buff")
        target:RemoveModifierByName("modifier_mark_target")
        --伤害
        local damage_table=
        {
            victim=target,
            attacker=caster,
            damage          = hability:GetSpecialValueFor("damage"),
            damage_type     = hability:GetAbilityDamageType(),
            damage_flags    = hability:GetAbilityTargetFlags(),
            ability= hability
        }
        ApplyDamage(damage_table)
    end

end

--modifier 名字：敌人减速debuff
modifier_ability_thdots_reisen2_01_debuff=class({})
LinkLuaModifier("modifier_ability_thdots_reisen2_01_debuff","scripts/vscripts/abilities/abilityreisen2.lua",LUA_MODIFIER_MOTION_NONE)

--modifier 基础判定
function modifier_ability_thdots_reisen2_01_debuff:IsHidden()       return false end
function modifier_ability_thdots_reisen2_01_debuff:IsPurgable()     return true end
function modifier_ability_thdots_reisen2_01_debuff:RemoveOnDeath()  return true end
function modifier_ability_thdots_reisen2_01_debuff:IsDebuff()       return true end

--modifier 修改列表
function modifier_ability_thdots_reisen2_01_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end

--modifier 修改函数
function modifier_ability_thdots_reisen2_01_debuff:GetModifierMoveSpeedBonus_Percentage()
    --if not IsServer() then return end
    return self:GetAbility():GetSpecialValueFor("slow_amount")
end

--modifier 名字: 英雄buff 加速
modifier_ability_thdots_reisen2_01_buff=class({})
LinkLuaModifier("modifier_ability_thdots_reisen2_01_buff","scripts/vscripts/abilities/abilityreisen2.lua",LUA_MODIFIER_MOTION_NONE)

--modifier 基础判定
function modifier_ability_thdots_reisen2_01_buff:IsHidden()         return false end
function modifier_ability_thdots_reisen2_01_buff:IsPurgable()       return false end
function modifier_ability_thdots_reisen2_01_buff:RemoveOnDeath()    return true end
function modifier_ability_thdots_reisen2_01_buff:IsDebuff()     return false end

--modifier 修改列表
function modifier_ability_thdots_reisen2_01_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_EVENT_ON_ORDER,
    }
    return funcs
end

--提供相位
function modifier_ability_thdots_reisen2_01_buff:CheckState()
	local state = {
	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	return state
end

--modifier 修改函数
function modifier_ability_thdots_reisen2_01_buff:GetModifierMoveSpeed_Absolute()
    --if not IsServer() then return end
    return self:GetAbility():GetSpecialValueFor("speed")
end

--modifier 触发事件：任何命令
function modifier_ability_thdots_reisen2_01_buff:OnOrder(keys)
    if not IsServer() then return end

    local caster=self:GetParent()
    local ability=self:GetAbility()

    if keys.unit==caster then 
        --消除加速buff
        if caster:HasModifier("modifier_ability_thdots_reisen2_01_buff") and self:GetAbility().cast_self==false then
            --caster:RemoveModifierByName("modifier_bloodseeker_thirst")
            caster:RemoveModifierByName("modifier_ability_thdots_reisen2_01_buff")
        end
    end
    self.cast_self=nil
end

--modifier 消失事件
function modifier_ability_thdots_reisen2_01_buff:OnDestroy()
    if not IsServer() then return end
    local ability=self:GetAbility()

    --删除特效，停止音效
    ParticleManager:DestroyParticle(ability.particle,true) 
    StopSoundOn("Ability.Windrun",ability.owner)
end

--技能1 end
---------------------------------------------------------------------------------

ability_thdots_reisen_2_02=class({})

function ability_thdots_reisen_2_02:IsHiddenWhenStolen()        return false end
function ability_thdots_reisen_2_02:IsRefreshable()             return true end
function ability_thdots_reisen_2_02:IsStealable()           return true end

--技能施法事件
function ability_thdots_reisen_2_02:OnSpellStart()
    if not IsServer() then return end
    local caster=self:GetCaster()
    local ability_duration=self:GetSpecialValueFor("duration")

    --天赋判定
    local abilityName="special_bonus_unique_Reisen_2_ability2_add_const"
    if caster:HasAbility(abilityName) and caster:FindAbilityByName(abilityName):GetLevel()>0 then 
        ability_duration = ability_duration+caster:FindAbilityByName(abilityName):GetSpecialValueFor("value")
    end 

    --确保刷新技能不影响特效
    if caster:HasModifier("modifier_ability_thdots_reisen2_02_buff_damageReduction") then
        caster:RemoveModifierByName("modifier_ability_thdots_reisen2_02_buff_damageReduction")
    end

    --加入modifier
    caster:AddNewModifier(caster,self,"modifier_ability_thdots_reisen2_02_buff_damageReduction",
    {duration=ability_duration})

    --音效播放，保存信息
    self.owner=caster
    EmitSoundOn("Hero_VoidSpirit.Pulse.Cast",caster)
    
    --特效创造
    self.particles={}
    local names={"particles/units/heroes/hero_void_spirit/void_spirit_exitportal_beam_c.vpcf",
                    "particles/units/heroes/hero_void_spirit/void_spirit_disruption_center.vpcf",
                "particles/units/heroes/hero_void_spirit/void_spirit_entryportal_beam_b.vpcf",
            "particles/units/heroes/hero_void_spirit/void_spirit_entryportal_beam.vpcf",}
    
    for i=1, #names do
        self.particles[i]=ParticleManager:CreateParticle(names[i],PATTACH_ROOTBONE_FOLLOW, caster) 
    end

end

--modifier 名字：减少伤害
modifier_ability_thdots_reisen2_02_buff_damageReduction=class({})
LinkLuaModifier("modifier_ability_thdots_reisen2_02_buff_damageReduction","scripts/vscripts/abilities/abilityreisen2.lua",LUA_MODIFIER_MOTION_NONE)

--modifier 基础判定
function modifier_ability_thdots_reisen2_02_buff_damageReduction:IsHidden()         return false end
function modifier_ability_thdots_reisen2_02_buff_damageReduction:IsPurgable()       return false end
function modifier_ability_thdots_reisen2_02_buff_damageReduction:RemoveOnDeath()    return true end
function modifier_ability_thdots_reisen2_02_buff_damageReduction:IsDebuff()     return false end

--modifier 修改列表
function modifier_ability_thdots_reisen2_02_buff_damageReduction:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
    return funcs
end

--modifier 消除事件
function modifier_ability_thdots_reisen2_02_buff_damageReduction:OnDestroy()
    if not IsServer() then return end

    --删除特效
    for i=1, #(self:GetAbility().particles) do
        ParticleManager:DestroyParticle(self:GetAbility().particles[i], true) 
    end

end

--modifier 触发事件：收到伤害，使用减免函数时候
function modifier_ability_thdots_reisen2_02_buff_damageReduction:GetModifierIncomingDamage_Percentage(keys)
    if not IsServer() then return end

    --基础信息
    local caster=self:GetCaster()
    local ability = self:GetAbility()
    local enemy=keys.attacker
    local ReceivedDamage=keys.damage
    local radius=ability:GetSpecialValueFor("radius")
    local ReceivedDamageType=keys.damage_type
    if keys.damage <= 5 then
        return
    end
    --如果是塔直接 return
    if enemy:IsTower() or enemy:IsBuilding() then
        return ability:GetSpecialValueFor("reduction")
    end

    --创造特效
    -- local names={
    -- "particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_explosion_alliance_wave.vpcf",
    -- "particles/econ/items/abaddon/abaddon_alliance/abaddon_death_coil_explosion_alliance_sparks.vpcf",
    -- "particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf",
    -- "particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_explosion_alliance_trail.vpcf"}

    -- for i=1, #names do
    --    local particle=ParticleManager:CreateParticle(names[i],PATTACH_ABSORIGIN_FOLLOW, caster)
    --    --立马摧毁特效 false 默认消除时间是4秒
    --    ParticleManager:DestroyParticle(particle,false)  
    -- end

    --反射
    local reflect_enemy=FindUnitsInRadius(
        caster:GetTeam(),
        caster:GetAbsOrigin(),
        nil,
        radius, 
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    --反射类型判定
    -- 真实伤害为1
    -- 魔法伤害为2
    -- 物理伤害为3
    -- 受到伤害类型为4
    --print("Receive Damage Type: ",ReceivedDamageType)
    self.returnType=DAMAGE_TYPE_PURE

    if ability:GetSpecialValueFor("reflect_type")==1 then
        self.returnType=DAMAGE_TYPE_PURE
    elseif ability:GetSpecialValueFor("reflect_type")==2 then
        self.returnType=DAMAGE_TYPE_MAGICAL
    elseif ability:GetSpecialValueFor("reflect_type")==3 then    
        self.returnType=DAMAGE_TYPE_PHYSICAL
    elseif ability:GetSpecialValueFor("reflect_type")==4 then
        self.returnType=ReceivedDamageType
    end

    for _,unit in pairs(reflect_enemy) do
        local damage_table=
        {
            victim=unit,
            attacker=caster,
            damage          = ReceivedDamage*(ability:GetSpecialValueFor("reflect_percent")/100),
            damage_type     = self.returnType,
            damage_flags    = DOTA_DAMAGE_FLAG_NONE,
            ability= self:GetAbility()
        }
        local effectIndex = ParticleManager:CreateParticle("particles/heroes/reisen2/reisen2_02_1.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(effectIndex, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(effectIndex, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(effectIndex)
        ApplyDamage(damage_table)
    end
    return ability:GetSpecialValueFor("reduction")
end

--技能2 end
---------------------------------------------------------------------------------

--技能3

ability_thdots_reisen_2_03=class({})

--被动技能链接modifier
function ability_thdots_reisen_2_03:GetIntrinsicModifierName()
    return  "modifier_ability_thdots_reisen2_03"
end

--modifier 名字: 被动技能
modifier_ability_thdots_reisen2_03=class({})
LinkLuaModifier("modifier_ability_thdots_reisen2_03","scripts/vscripts/abilities/abilityreisen2.lua",LUA_MODIFIER_MOTION_NONE)

--modifier 基础判定
function modifier_ability_thdots_reisen2_03:IsHidden()      return false end
function modifier_ability_thdots_reisen2_03:IsPurgable()        return false end
function modifier_ability_thdots_reisen2_03:RemoveOnDeath()     return false end
function modifier_ability_thdots_reisen2_03:IsDebuff()      return false end

--modifier 修改列表
function modifier_ability_thdots_reisen2_03:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACKED,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_MODIFIER_ADDED,
    }
    return funcs
end

--modifier 触发事件：创造

function modifier_ability_thdots_reisen2_03:OnCreated()
    --基础信息
    if not IsServer() then return end
    self.caster=self:GetParent()
    self.ability= self:GetAbility()
    self.count= 0
    self.max_count=0
    self:SetStackCount(self.count)
    --计时
    self:StartIntervalThink(1)
end

function modifier_ability_thdots_reisen2_03:OnAttacked(keys)
    if not IsServer() then return end

    --天赋修改信息
    local abilityName="special_bonus_unique_Reisen_2_ability3_multiplier"
    local temp=1

    --如果目标是施法者,非英雄单位不生效
    if keys.target==self:GetParent() and not keys.target:IsIllusion() and keys.attacker:IsHero() then
        --天赋判定：倍数
        if self.caster:HasAbility(abilityName) and self.caster:FindAbilityByName(abilityName):GetLevel()>0 then 
            temp = temp*self.caster:FindAbilityByName(abilityName):GetSpecialValueFor("value")
        end 
        --增加cd count
        if self.count < self.max_count and not self.caster:HasModifier("modifier_ability_thdots_reisen2_03_attack_buff") then
            self.count=self.count+temp
            self:SetStackCount(self.count)
        end
        --如果大于或者等于cd最高值 而且没有攻击buff
        if self.count >= self.max_count and not self.caster:HasModifier("modifier_ability_thdots_reisen2_03_attack_buff") then
            self.caster:AddNewModifier(self.caster,self.ability,"modifier_ability_thdots_reisen2_03_attack_buff", {})
            self.count=0
            self:SetStackCount(self.count)
        end
    end
end

function modifier_ability_thdots_reisen2_03:OnAttackLanded(keys)
    if not IsServer() then return end

    --天赋修改信息
    local abilityName="special_bonus_unique_Reisen_2_ability3_multiplier"
    local temp=1
    --如果攻击是施法者

    if keys.attacker==self:GetParent() and not keys.attacker:IsIllusion() then

        --天赋判定：倍数
        if self.caster:HasAbility(abilityName) and self.caster:FindAbilityByName(abilityName):GetLevel()>0 then 
            temp = temp*self.caster:FindAbilityByName(abilityName):GetSpecialValueFor("value")
        end 
        --增加cd count
        if self.count < self.max_count and not self.caster:HasModifier("modifier_ability_thdots_reisen2_03_attack_buff") then
            self.count=self.count+temp
            self:SetStackCount(self.count)
        end
        --如果大于或者等于cd最高值 而且没有攻击buff
        if self.count >= self.max_count and not self.caster:HasModifier("modifier_ability_thdots_reisen2_03_attack_buff") then
            self.caster:AddNewModifier(self.caster,self.ability,"modifier_ability_thdots_reisen2_03_attack_buff", {})
            self.count=0
            self:SetStackCount(self.count)
        end
    end

end

function modifier_ability_thdots_reisen2_03:OnIntervalThink()
    if not IsServer() then return end

    local abilityName="special_bonus_unique_Reisen_2_ability3_multiplier"
    local temp=1
    --天赋判定：倍数
    if self.caster:HasAbility(abilityName) and self.caster:FindAbilityByName(abilityName):GetLevel()>0 then 
        temp = temp*self.caster:FindAbilityByName(abilityName):GetSpecialValueFor("value")
    end 

    --每秒思考
    --得到cd最高值
    self.max_count=self.ability:GetSpecialValueFor("cooldown")

    --如果大于或者等于cd最高值 而且没有攻击buff
    if self.count>=self.max_count and not self.caster:HasModifier("modifier_ability_thdots_reisen2_03_attack_buff") then
        self.caster:AddNewModifier(self.caster,self.ability,"modifier_ability_thdots_reisen2_03_attack_buff", {})
    end

    --如果已经有攻击buff 重置到0
    if self.caster:HasModifier("modifier_ability_thdots_reisen2_03_attack_buff") then
        self.count=0
        self:SetStackCount(self.count)
    elseif self.caster:IsAlive() then
        --每秒加一秒cd值
        self.count=self.count+temp
        self:SetStackCount(self.count)
    end  

end

--modifier 名字： 被动技能 攻击buff
modifier_ability_thdots_reisen2_03_attack_buff=class({})
LinkLuaModifier("modifier_ability_thdots_reisen2_03_attack_buff","scripts/vscripts/abilities/abilityreisen2.lua",LUA_MODIFIER_MOTION_NONE)

--modifier 基础判定
function modifier_ability_thdots_reisen2_03_attack_buff:IsHidden()      return false end
function modifier_ability_thdots_reisen2_03_attack_buff:IsPurgable()        return false end
function modifier_ability_thdots_reisen2_03_attack_buff:RemoveOnDeath()     return false end
function modifier_ability_thdots_reisen2_03_attack_buff:IsDebuff()      return false end


--modifier 修改列表
function modifier_ability_thdots_reisen2_03_attack_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
    return funcs
end

--增加1000攻速
--无法突破最高攻速
--最高攻速是攻击间隔决定的
function modifier_ability_thdots_reisen2_03_attack_buff:GetModifierAttackSpeedBonus_Constant()
    --if not IsServer() then return end
    return 1000
end

--modifier 事件：攻击成功
function modifier_ability_thdots_reisen2_03_attack_buff:OnAttackLanded(keys)
    if not IsServer() then return end
    local caster= self:GetCaster()
    local enemy= keys.target
    local ability= self:GetAbility()
    --如果攻击者是施法者
    if keys.attacker==caster then

        --创造特效
        local name="particles/units/heroes/hero_void_spirit/astral_step/void_spirit_astral_step_dmg_blood.vpcf"
        local particle=ParticleManager:CreateParticle(name,PATTACH_RENDERORIGIN_FOLLOW,keys.target)
        --立马摧毁特效 false 默认消除时间是4秒
        ParticleManager:DestroyParticle(particle, false)

        --音效
        EmitSoundOn("Hero_VoidSpirit.AstralStep.MarkExplosionAOE", caster)

        --计算伤害
        local total_damage= (ability:GetSpecialValueFor("damage"))+(caster:GetAgility()*ability:GetSpecialValueFor("agility_bonus"))
        local damage_table=
        {
            victim=enemy,
            attacker=caster,
            damage          = total_damage,
            damage_type     = DAMAGE_TYPE_PURE,
            damage_flags    = DOTA_DAMAGE_FLAG_NONE,
            ability= self:GetAbility()
        }
        if not enemy:IsBuilding() then 
            ApplyDamage(damage_table)
            --治疗
            local heal=total_damage*(ability:GetSpecialValueFor("heal_percent")/100)
            caster:Heal(heal,caster)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, heal, nil)
        end
        --消除modifier
        caster:RemoveModifierByName("modifier_ability_thdots_reisen2_03_attack_buff")
    end
end

--技能3 end
---------------------------------------------------------------------------------


--技能4
ability_thdots_reisen_2_ultimate=class({})

function ability_thdots_reisen_2_ultimate:IsHiddenWhenStolen()      return false end
function ability_thdots_reisen_2_ultimate:IsRefreshable()           return true end
function ability_thdots_reisen_2_ultimate:IsStealable()             return true end

--万宝槌效果：允许眩晕使用
function ability_thdots_reisen_2_ultimate:GetBehavior(value)
    local caster = self:GetCaster()
    if caster:HasModifier("modifier_item_wanbaochui") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
    end
    return self.BaseClass.GetBehavior(self)
end

--技能4 施法事件
function ability_thdots_reisen_2_ultimate:OnSpellStart()
    if not IsServer() then return end
    local caster=self:GetCaster()

    --保存：天赋信息
    local abilityName="special_bonus_unique_Reisen_2_ability4_cooldown_reduce"
    self.original_attack_time=caster:GetBaseAttackTime()
    self.Caster=caster

    --万宝槌判定：给自己驱散
    if caster:HasModifier("modifier_item_wanbaochui") then
        caster:Purge(false, true, false, true, false)
    end

    --天赋判定：减少cd
    if caster:HasAbility(abilityName) and caster:FindAbilityByName(abilityName):GetLevel()>0 then 
        local cooldown = self:GetCooldown(self:GetLevel())-caster:FindAbilityByName(abilityName):GetSpecialValueFor("value")
        self:EndCooldown()
        self:StartCooldown(cooldown)
    end 
    --确保刷新技能不影响 特效
    if caster:HasModifier("modifier_ability_thdots_reisen2_ultimate") then
        caster:RemoveModifierByName("modifier_ability_thdots_reisen2_ultimate")
    end
    --加入modifer
    
    caster:AddNewModifier(caster,self,"modifier_ability_thdots_reisen2_ultimate",{})
    -- caster:AddNewModifier(caster,self,"modifier_ability_thdots_reisen2_ultimate_dealy",{duration = 2})
    caster:AddNewModifier(caster,self,"modifier_ability_thdots_reisen2_ultimate_dealy",{duration = self:GetSpecialValueFor("delay_duration")})




    --特效
    self.particles={}
    local names={
        ["particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_buff.vpcf"]=PATTACH_ROOTBONE_FOLLOW,
        ["particles/units/heroes/hero_invoker_kid/invoker_kid_forge_spirit_ambient_fire.vpcf"]=PATTACH_ROOTBONE_FOLLOW,
        ["particles/units/heroes/hero_arc_warden/arc_warden_tempest_cast_ring.vpcf"]=PATTACH_ABSORIGIN_FOLLOW,
        ["particles/units/heroes/hero_void_spirit/planeshift/void_spirit_planeshift.vpcf"]=PATTACH_ROOTBONE_FOLLOW}
    
    local temp=1
    for k,v in pairs(names) do
        self.particles[temp]=ParticleManager:CreateParticle(k,v,caster)
        temp=temp+1 
    end

    --音效
    EmitSoundOn("Hero_TrollWarlord.BattleTrance.Cast",caster)
    
    --斧王咆哮 使用原版dota的modifier
    -- local call_enemy=FindUnitsInRadius(
    --     caster:GetTeam(),
    --     caster:GetAbsOrigin(),
    --     nil,
    --     self:GetSpecialValueFor("radius"), 
    --     DOTA_UNIT_TARGET_TEAM_ENEMY,
    --     DOTA_UNIT_TARGET_ALL,
    --     DOTA_UNIT_TARGET_FLAG_NONE,
    --     FIND_ANY_ORDER,
    --     false
    -- )
    -- for _,unit in pairs(call_enemy) do
    --     unit:AddNewModifier(caster,self,"modifier_ability_thdots_reisen2_ultimate_berserkers_call",{duration=self:GetSpecialValueFor("berserker_call_duration")})
    -- end
    
end
--允许被驱散
modifier_ability_thdots_reisen2_ultimate_berserkers_call=class({})
LinkLuaModifier("modifier_ability_thdots_reisen2_ultimate_berserkers_call","scripts/vscripts/abilities/abilityreisen2.lua",LUA_MODIFIER_MOTION_NONE)
--modifier 基础判定
function modifier_ability_thdots_reisen2_ultimate_berserkers_call:IsHidden()        return false end
function modifier_ability_thdots_reisen2_ultimate_berserkers_call:IsPurgable()      return true end
function modifier_ability_thdots_reisen2_ultimate_berserkers_call:RemoveOnDeath()   return true end
function modifier_ability_thdots_reisen2_ultimate_berserkers_call:IsDebuff()        return true end

--modifier 修改列表
function modifier_ability_thdots_reisen2_ultimate_berserkers_call:DeclareFunctions()
    local funcs = {
    }
    
    return funcs
end

function modifier_ability_thdots_reisen2_ultimate_berserkers_call:OnCreated()
    if not IsServer() then return end
    local caster=self:GetCaster()
    local enemy=self:GetParent()
    enemy:AddNewModifier(caster,self:GetAbility(),"modifier_axe_berserkers_call",{duration=self:GetAbility():GetSpecialValueFor("berserker_call_duration")})
end

function modifier_ability_thdots_reisen2_ultimate_berserkers_call:OnDestroy()
    if not IsServer() then return end
    local enemy=self:GetParent()
    enemy:RemoveModifierByName("modifier_axe_berserkers_call")
end


--modifier 名字：大招攻速移速buff
modifier_ability_thdots_reisen2_ultimate = class({})
LinkLuaModifier("modifier_ability_thdots_reisen2_ultimate","scripts/vscripts/abilities/abilityreisen2.lua",LUA_MODIFIER_MOTION_NONE)

--modifier 基础判定
function modifier_ability_thdots_reisen2_ultimate:IsHidden()        return false end
function modifier_ability_thdots_reisen2_ultimate:IsPurgable()      return false end
function modifier_ability_thdots_reisen2_ultimate:RemoveOnDeath()   return true end
function modifier_ability_thdots_reisen2_ultimate:IsDebuff()        return false end

--modifier 修改列表
function modifier_ability_thdots_reisen2_ultimate:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    
    return funcs
end

function modifier_ability_thdots_reisen2_ultimate:OnCreated()
    if not IsServer() then return end

    --基础信息
    local caster=self:GetCaster()
    local abilityName="special_bonus_unique_Reisen_2_ability4_reduce_attacktime"

    --天赋判定：减少攻击间隔
    if caster:HasAbility(abilityName) and caster:FindAbilityByName(abilityName):GetLevel()>0 then
        caster:SetBaseAttackTime(caster:FindAbilityByName(abilityName):GetSpecialValueFor("value"))
    end

    --持续时间信息
    self.buff_duration=self:GetAbility():GetSpecialValueFor("duration")
    self:SetStackCount(self.buff_duration)
    self:StartIntervalThink(1)
end

--modifier 消除事件
function modifier_ability_thdots_reisen2_ultimate:OnDestroy()
    if not IsServer() then return end
    --print("Called Destroy")

    --重置攻击间隔
    self:GetAbility().Caster:SetBaseAttackTime(self:GetAbility().original_attack_time)

    --删除特效
    for i=1, #self:GetAbility().particles do
        ParticleManager:DestroyParticle(self:GetAbility().particles[i],true)
    end
end

function modifier_ability_thdots_reisen2_ultimate:OnIntervalThink()
    if not IsServer() then return end

    if self.buff_duration > self:GetAbility():GetSpecialValueFor("ultimate_limit") then
        self.buff_duration= self:GetAbility():GetSpecialValueFor("ultimate_limit")
    end

    self:SetStackCount(self.buff_duration)

    --如果持续时间为0 消除modifier
    if self.buff_duration ==0 then
        local caster =self:GetCaster()
        caster:RemoveModifierByName("modifier_ability_thdots_reisen2_ultimate")
    end
    --如果大于0 减少1秒
    if self.buff_duration > 0 then
        self.buff_duration = self.buff_duration-1
        self:SetStackCount(self.buff_duration)
    end
    --print("self. ultimate duration: ",self.buff_duration)
end

--modifier 事件：攻击成功
function modifier_ability_thdots_reisen2_ultimate:OnAttackLanded(keys)
    if not IsServer() then return end
    --基础信息
    local ability=self:GetAbility()
    local enemy=keys.target

    --如果攻击者是施法者 + 对象是英雄 + buff低于最高值 则增加持续时间
    if keys.attacker==self:GetCaster() and enemy:IsHero() and self.buff_duration < ability:GetSpecialValueFor("ultimate_limit") then
        self.buff_duration=self.buff_duration + ability:GetSpecialValueFor("ultimate_duration_increase_by")
        self:SetStackCount(self.buff_duration)
    end

end

--增加移速百分比
function modifier_ability_thdots_reisen2_ultimate:GetModifierMoveSpeedBonus_Percentage()
    --if not IsServer() then return end
    return self:GetAbility():GetSpecialValueFor("movement_speed")
end

--增加攻速常值
function modifier_ability_thdots_reisen2_ultimate:GetModifierAttackSpeedBonus_Constant()
    --if not IsServer() then return end
    return self:GetAbility():GetSpecialValueFor("attack_speed")
end

modifier_ability_thdots_reisen2_ultimate_dealy=class({})

LinkLuaModifier("modifier_ability_thdots_reisen2_ultimate_dealy","scripts/vscripts/abilities/abilityreisen2.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_reisen2_ultimate_dealy:IsHidden()        return false end
function modifier_ability_thdots_reisen2_ultimate_dealy:IsPurgable()      return false end
function modifier_ability_thdots_reisen2_ultimate_dealy:RemoveOnDeath()   return true end
function modifier_ability_thdots_reisen2_ultimate_dealy:IsDebuff()        return false end

function modifier_ability_thdots_reisen2_ultimate_dealy:DeclareFunctions()
    local funcs = {

    }
    
    return funcs
end

function modifier_ability_thdots_reisen2_ultimate_dealy:OnDestroy()
    if not IsServer() then return end
    local caster=self:GetCaster()
    local ability=self:GetAbility()
    local radius = ability:GetSpecialValueFor("radius")
    local particle = ParticleManager:CreateParticle("particles/econ/items/axe/axe_helm_shoutmask/axe_beserkers_call_owner_shoutmask.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particle, 2, Vector(radius, radius, radius))
    ParticleManager:ReleaseParticleIndex(particle)

    local call_enemy=FindUnitsInRadius(
        caster:GetTeam(),
        caster:GetAbsOrigin(),
        nil,
        ability:GetSpecialValueFor("radius"), 
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    for _,unit in pairs(call_enemy) do
        unit:AddNewModifier(caster,ability,"modifier_ability_thdots_reisen2_ultimate_berserkers_call",{duration=ability:GetSpecialValueFor("berserker_call_duration")})
    end

end




---------------------------------------------------------------------------------

--天生技能
ability_thdots_reisen_2_04=class({})

function ability_thdots_reisen_2_04:GetIntrinsicModifierName()
    return "modifier_ability_thdots_reisen2_04"
end

--modifier 名字
modifier_ability_thdots_reisen2_04=class({})
LinkLuaModifier("modifier_ability_thdots_reisen2_04","scripts/vscripts/abilities/abilityreisen2.lua",LUA_MODIFIER_MOTION_NONE)

--modifier 基础判定
function modifier_ability_thdots_reisen2_04:IsHidden()      return false end
function modifier_ability_thdots_reisen2_04:IsPurgable()        return false end
function modifier_ability_thdots_reisen2_04:RemoveOnDeath()     return false end
function modifier_ability_thdots_reisen2_04:IsDebuff()      return false end

--modifier 修改列表
function modifier_ability_thdots_reisen2_04:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_ability_thdots_reisen2_04:OnCreated()
    if not IsServer() then end
    --如果不是4级
    --这是为了尝试取消thinker的
    
    if self:GetAbility():GetLevel()~=4 then
        self:StartIntervalThink(1.0)
    end
end

function modifier_ability_thdots_reisen2_04:OnIntervalThink()
    if not IsServer() then return end
    --print("think hero level")

    --基础信息
    local caster=self:GetParent()
    local ability=self:GetAbility()

    --天生技能升级：5， 10， 15
    if caster:GetLevel()>=5 and ability:GetLevel()==1 then
        ability:SetLevel(ability:GetLevel()+1)
    elseif caster:GetLevel()>=10 and ability:GetLevel()==2 then
        ability:SetLevel(ability:GetLevel()+1)
    elseif caster:GetLevel()>=15 and ability:GetLevel()==3 then
        ability:SetLevel(ability:GetLevel()+1)
        --结束计时thinker
        self:StartIntervalThink(-1)
    end
end

--modifier 事件：攻击成功
function modifier_ability_thdots_reisen2_04:OnAttackLanded( keys )
    if not IsServer() then end
    --如果攻击者是 modifier持有者 而且自己不是幻象 执行分裂攻击
    --这个代码是 valve 提供的sven 例子
    if keys.attacker == self:GetParent() then
        self.cleaveDamage= self:GetAbility():GetSpecialValueFor("cleave_damage")
        self.radius=self:GetAbility():GetSpecialValueFor("cleave_range")
        local target = keys.target
        local cleaveDamage = ( self.cleaveDamage * keys.damage ) / 100.0
        if not keys.attacker:HasModifier("modifier_ability_thdots_reisen2_ultimate") then
            self.effect="particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf"
        end
        if keys.attacker:HasModifier("modifier_ability_thdots_reisen2_ultimate") then
            self.effect="particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength.vpcf"
        end
        DoCleaveAttack( self:GetParent(), target, self:GetAbility(), cleaveDamage, self.radius,self.radius, self.radius, self.effect )
    end

    return 0
end

--天生技能 end


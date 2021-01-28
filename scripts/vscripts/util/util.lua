
STARTING_GOLD = 500--650
DEBUG = true
GameMode = nil

TRUE = 1
FALSE = 0


function GetDistanceBetweenTwoVec2D(a, b)
    local xx = (a.x-b.x)
    local yy = (a.y-b.y)
    return math.sqrt(xx*xx + yy*yy)
end

function GetRadBetweenTwoVec2D(a,b)
	local y = b.y - a.y
	local x = b.x - a.x
	return math.atan2(y,x)
end
--aVec:原点向量
--rectOrigin：单位原点向量
--rectWidth：矩形宽度
--rectLenth：矩形长度
--rectRad：矩形相对Y轴旋转角度
function IsRadInRect(aVec,rectOrigin,rectWidth,rectLenth,rectRad)
	local aRad = GetRadBetweenTwoVec2D(rectOrigin,aVec)
	local turnRad = aRad + (math.pi/2 - rectRad)
	local aRadius = GetDistanceBetweenTwoVec2D(rectOrigin,aVec)
	local turnX = aRadius*math.cos(turnRad)
	local turnY = aRadius*math.sin(turnRad)
	local maxX = rectWidth/2
	local minX = -rectWidth/2
	local maxY = rectLenth
	local minY = 0
	if(turnX<maxX and turnX>minX and turnY>minY and turnY<maxY)then
		return true
	else
	    return false
	end
	return false
end

function IsRadBetweenTwoRad2D(a,rada,radb)
    local maxrad = math.max(rada,radb)
    local minrad = math.min(rada,radb)
    
    if rada >= 0 and radb >= 0 then
        if(a<=maxrad and a>=minrad)then
            print("true")
            return true
        end
    elseif rada >=0 and radb < 0 then

    elseif rada < 0 and radb >= 0 then
        if(a<maxrad and a>minrad)then
            print("true")
            return true
        end
    elseif rada < 0 and radb < 0 then
        if(a<maxrad and a>minrad)then
            print("true")
            return true
        end
    end

	return false
end


-- cx = 目标的x
-- cy = 目标的y
-- ux = math.cos(theta)   (rad是caster和target的夹角的弧度制表示)
-- uy = math.sin(theta)
-- r = 目标和原点之间的距离
-- theta = 夹角的弧度制
-- px = 原点的x
-- py = 原点的y
-- 返回 true or false(目标是否在扇形内，在的话=true，不在=false)

function IsPointInCircularSector(cx,cy,ux,uy,r,theta,px,py)
    local dx = px - cx
    local dy = py - cy

    local length = math.sqrt(dx * dx + dy * dy)

    if (length > r) then
        return false
    end

    local vec = Vector(dx,dy,0):Normalized()
    return math.acos(vec.x * ux + vec.y * uy) < theta
 end 


function SetTargetToTraversable(target)
    local vecTarget = target:GetOrigin() 
    local vecGround = GetGroundPosition(vecTarget, nil)

    UnitNoCollision(target,target,0.1)
end
 

function ParticleManager:DestroyParticleSystem(effectIndex,bool)
    if(bool)then
        ParticleManager:DestroyParticle(effectIndex,true)
        ParticleManager:ReleaseParticleIndex(effectIndex) 
    else
        Timer.Wait 'Effect_Destroy_Particle' (4,
            function()
                ParticleManager:DestroyParticle(effectIndex,true)
                ParticleManager:ReleaseParticleIndex(effectIndex) 
            end
        )
    end
end

function ParticleManager:DestroyParticleSystemTime(effectIndex,time)
    Timer.Wait 'Effect_Destroy_Particle_Time' (time,
        function()
            ParticleManager:DestroyParticle(effectIndex,true)
            ParticleManager:ReleaseParticleIndex(effectIndex) 
        end
    )
end

function is_spell_blocked(target,caster)
    if caster ~= nil then 
        if caster:GetTeam() == target:GetTeam() then
            return false
        end
    end
	if target:HasModifier("modifier_item_sphere_target") then
		target:RemoveModifierByName("modifier_item_sphere_target")  --The particle effect is played automatically when this modifier is removed (but the sound isn't).
		target:EmitSound("DOTA_Item.LinkensSphere.Activate")
		return true
	end
	return false
end

function THDReduceCooldown(ability,value)
    if value == 0 then return end
    local cooldown=(ability:GetCooldown(ability:GetLevel())+value)*(ability:GetCooldownTimeRemaining()/ability:GetCooldown(ability:GetLevel()))
    ability:EndCooldown()
    ability:StartCooldown(cooldown)
end

function FindTelentValue(caster,name)
    local ability = caster:FindAbilityByName(name)
    if ability~=nil then
        return ability:GetSpecialValueFor("value")
    else
        return 0
    end
end




function FindValueTHD(name,ability)

    if ability == nil then
        return 0
    end
    local thdvalue = ability:GetLevelSpecialValueFor(name, ability:GetLevel() - 1 )
--  print(thdvalue)
    return thdvalue

end

function print_r ( t )   --这个t是table，可以查看并打印keys里的所有table子类，一般给t传个keys
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

function IsNotLunchbox_ability(ability)  --御币不能充能的技能
    if ability ~= nil then
        if ability:GetName() == "ability_thdots_patchouli_fire"
        or ability:GetName() == "ability_thdots_patchouli_water"
        or ability:GetName() == "ability_thdots_patchouli_wood"
        or ability:GetName() == "ability_thdots_patchouli_metal"
        or ability:GetName() == "ability_thdots_patchouli_earth" 
        then return true end
        if ability:IsToggle() or ability:GetAbilityType() == 3 then  --GetAbilityType() == 3 是HIDDEN技能，一般是天生，不触发
            return true
        end
    end
    return false
end

function CastRang_Calculate(caster,point,range)
    local distance = (point - caster:GetOrigin()):Length2D()
    if distance >= range then
        distance = range
    end
    return distance
end

function DeleteDummy(targets)
    for i=1,#targets do
        if targets[i]:HasModifier("dummy_unit") then
            table.remove(targets, i)
            DeleteDummy(targets)
        end
    end
end

function DecideMaxRange(caster,point,max_range)
    local targetPoint = point
    local vecCaster = caster:GetOrigin()
    local maxRange = max_range
    local pointRad = GetRadBetweenTwoVec2D(vecCaster,targetPoint)
    if(GetDistanceBetweenTwoVec2D(vecCaster,targetPoint)<=maxRange)then
        return targetPoint
    else
        local blinkVector = Vector(math.cos(pointRad)*maxRange,math.sin(pointRad)*maxRange,0) + vecCaster
        return blinkVector
    end
end

function IsTHDImmune(target) --THD的魔免BUFF，如龙星，彩光风铃等
    if target:HasModifier("modifier_item_dragon_star_buff") --道具:龙星
        or target:HasModifier("modifier_meirin02_buff") --红美铃：彩光风铃
        then 
        return true
    else
        return false
    end
end

function GetAllModifierName(caster)
    print("--------------",caster:GetName(),"modifier list :--------------")
    for i=0,8 do
         if caster:GetModifierNameByIndex(i) ~= "" then
             print(caster:GetModifierNameByIndex(i))
         end
    end
    print("---------------end------------")
end

function GetAllAbilityName(caster)
    print("--------------",caster:GetName(),"ability list :--------------")
     for i=0,8 do 
         if caster:GetModifierNameByIndex(i) ~= "" then
             print(caster:GetModifierNameByIndex(i))
         end
     end
    print("---------------end------------")
end

function IsTHDReflect(target) --THD的反弹伤害BUG
    if target:HasModifier("modifier_thdots_medicine03_OnTakeDamage") --毒人偶毒
        or target:HasModifier("modifier_item_frock_OnTakeDamage") --毒裙
        or target:HasModifier("OnMerlin04TakeDamage") --小号大
        then 
        return true
    else
        return false
    end
end

function IsNoBugModifier(modifier)
    if modifier ~= nil and modifier:GetName() ~= "" then
        if modifier:GetName() == "modifier_scripted_motion_controller" then
            return false
        end
        if modifier:GetName() == "modifier_skewer_disable_target" 
            or modifier:GetName() == "modifier_skewer_datadriven"
            or modifier:GetName() == "modifier_skewer_disable_caster"
            or modifier:GetName() == "modifier_scripted_motion_controlleris"
            then 
                -- print("-----------------------------------")
                -- print(modifier:GetName().." ：is Bug Modifier")
                -- print(modifier.parsee01)
                -- print("is Bug Modifier")
                return false
        else
            print(modifier:GetName()..":is NO Modifier")
                -- print(modifier.parsee01)
            return true
        end
    end
end
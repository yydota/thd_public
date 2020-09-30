
function ThdotsJumpTrigger( data )
	local target = data.activator
	local caller = data.caller
	local vecLocation = thisEntity:GetOrigin()
	local vecTarget = target:GetOrigin()
	local jumpRad = GetRadBetweenTwoVec2D(vecTarget,vecLocation)
	local jumpS = vecTarget.z - vecLocation.z
	local jumpDistance = GetDistanceBetweenTwoVec2D(vecLocation,vecTarget)
	local jumpSpeed = 30
	local fallSpeed = 100
	local fallG = 10
	if target:HasModifier("modifier_ability_thdots_yorihime_01_move") --一鸡冲刺
		or target:HasModifier("modifier_ability_thdots_chen01") --橙滚球
		or target:HasModifier("modifier_kagerou_moving") --影狼跳
		then 
		return
	end
    UnitPauseTarget(target,target,2)
    local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/reimu/reimu_01_effect.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(effectIndex, 0, vecTarget)
	ParticleManager:SetParticleControl(effectIndex, 2, vecTarget)
	ParticleManager:ReleaseParticleIndex(effectIndex)
	target:EmitSound("Visage_Familar.StoneForm.Cast")

	local vecMove
	if target ~= nil then
		Timer.Loop 'hero_jump_trigger_to_location' (0.02, 250,
			function()
				vecMove = target:GetOrigin()
				vecGround = GetGroundPosition(vecMove,nil)
				
				fallSpeed = fallSpeed - fallG
			    vecMove = vecMove + Vector(math.cos(jumpRad)*jumpSpeed,math.sin(jumpRad)*jumpSpeed,fallSpeed)
				if(vecMove.z<=vecGround.z)then
					SetTargetToTraversable(target)
					target:RemoveModifierByName("modifier_stunsystem_pause")
					return true
				end
				target:SetOrigin(vecMove)
			end
		)
	end
end

function ThdotsJumpTrigger_bl_top( data )
	local target = data.activator
	local caller = data.caller
	local vecLocation = thisEntity:GetOrigin()
	local vecTarget = target:GetOrigin()
	local jumpRad = GetRadBetweenTwoVec2D(vecTarget,vecLocation)
	local jumpS = vecTarget.z - vecLocation.z
	local jumpDistance = GetDistanceBetweenTwoVec2D(vecLocation,vecTarget)
	local jumpSpeed = 50
	local fallSpeed = 100
	local fallG = 10
	
    UnitPauseTarget(target,target,2)
	local vecMove
	if target ~= nil then
		Timer.Loop 'hero_jump_trigger_to_location' (0.02, 250,
			function()
				vecMove = target:GetOrigin()
				vecGround = GetGroundPosition(vecMove,nil)
				
				fallSpeed = fallSpeed - fallG
			    vecMove = vecMove + Vector(math.cos(jumpRad)*jumpSpeed,math.sin(jumpRad)*jumpSpeed,fallSpeed)
				if(vecMove.z<=vecGround.z)then
					SetTargetToTraversable(target)
					target:RemoveModifierByName("modifier_stunsystem_pause")
					local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/reimu/reimu_01_effect.vpcf", PATTACH_CUSTOMORIGIN, target)
					ParticleManager:SetParticleControl(effectIndex, 0, vecTarget)
					ParticleManager:SetParticleControl(effectIndex, 2, vecTarget)
					ParticleManager:ReleaseParticleIndex(effectIndex)
					target:EmitSound("Visage_Familar.StoneForm.Cast")
					return true
				end
				target:SetOrigin(vecMove)
			end
		)
	end
end


function  dasudhakd( data )
	print("dasdasdada")
end

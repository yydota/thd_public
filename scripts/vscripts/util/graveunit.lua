	
	function UnitGraveTarget( caster,target )
		local dummy = CreateUnitByName("npc_dummy_unit", 
	    	                           target:GetAbsOrigin(), 
									false, 
								    caster, 
									caster, 
									caster:GetTeamNumber()
									)
		dummy:SetOwner(caster)
		dummy:AddAbility("dazzle_shallow_grave") 
		--Ѱ�ҵ�λ�ͷż���
		local STUN_TARGET = dummy:FindAbilityByName("dazzle_shallow_grave")
		
		STUN_TARGET:SetLevel(1)
		
		dummy:CastAbilityOnTarget(target, STUN_TARGET, 0 )
    end
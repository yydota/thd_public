
Patchouli_Abilities = {
	1 = {
		1 = "ability_thdots_patchouli_fire_fire",
		2 = "ability_thdots_patchouli_fire_water",
		3 = "ability_thdots_patchouli_fire_wood",
		4 = "ability_thdots_patchouli_fire_metal",
		5 = "ability_thdots_patchouli_fire_earth",
	},
	2 = {
		2 = "ability_thdots_patchouli_water_water",
		3 = "ability_thdots_patchouli_water_wood",
		4 = "ability_thdots_patchouli_water_metal",
		5 = "ability_thdots_patchouli_water_earth",
	},
	3 = {
		3 = "ability_thdots_patchouli_wood_wood",
		4 = "ability_thdots_patchouli_wood_metal",
		5 = "ability_thdots_patchouli_wood_earth",
	},
	4 = {
		4 = "ability_thdots_patchouli_metal_metal",
		5 = "ability_thdots_patchouli_metal_earth",
	},
	5 = {
		5 = "ability_thdots_patchouli_earth_earth",
	},
}

Patchouli_Elements = {
	1 = 0 
	2 = 0
	3 = 0
	4 = 0
	5 = 0
}

Patchouli_Elements_now = { }

local function UpdateElement()
	
	abilityfire = npcBot:GetAbilityByName( "ability_thdots_patchouli_fire" );
	abilitywater = npcBot:GetAbilityByName( "ability_thdots_patchouli_water" );
	abilitywood = npcBot:GetAbilityByName( "ability_thdots_patchouli_wood" );
	abilitymetal = npcBot:GetAbilityByName( "ability_thdots_patchouli_metal" );
	abilityearth = npcBot:GetAbilityByName( "ability_thdots_patchouli_earth" );

	Patchouli_Elements[1] = abilityfire:GetLevel();
	Patchouli_Elements[2] = abilitywater:GetLevel();
	Patchouli_Elements[3] = abilitywood:GetLevel();
	Patchouli_Elements[4] = abilitymetal:GetLevel();
	Patchouli_Elements[5] = abilityearth:GetLevel();
	
end

local function GetAbilityByElement( E1, E2 ) -- Must E1 <= E2
	if Patchouli_Elements[E1] > 0 and Patchouli_Elements[E2] > 0 then
		return npcBot:GetAbilityByName(Patchouli_Abilities[E1][E2])
	end
	return nil
end

----------------------------------------------------------------------------------------------------

local function IsItemAvailable(item_name)
    local npcBot = GetBot()
    for i = 0, 5 do
        local item = npcBot:GetItemInSlot(i)
        if (item ~= nil) then
            if (item:GetName() == item_name) then
				return item
            end
        end
    end
    return nil
end

----------------------------------------------------------------------------------------------------

cast01Desire = 0;
cast02Desire = 0;
cast03Desire = 0;
cast04Desire = 0;

function MyItemUsageThink()
	
	local npcBot = GetBot();

	-- Check if we're already using an ability
	if ( npcBot:IsMuted() or npcBot:IsUsingAbility() ) then return end;

	item_stun = IsItemAvailable( "item_yuetufensuijvren" )
	if item_stun == nil then
		item_stun = IsItemAvailable( "item_pocket_watch" )
	end
	
	if ( item_stun~=nil and item_stun:IsFullyCastable() )
	then 
		--print("stun item exist")
		castItemStunDesire, castItemStunTarget = ConsiderItemStun()
		if ( castItemStunDesire > 0 ) 
		then
			--print("stun luanch")
			npcBot:Action_UseAbilityOnEntity( item_stun, castItemStunTarget );
			return;
		end
	end

end

function AbilityUsageThink()

	MyItemUsageThink();
	local npcBot = GetBot();

	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() ) then return end;
	
	UpdateElement();
	
	abilityfire = npcBot:GetAbilityByName( "ability_thdots_patchouli_fire" );
	abilitywater = npcBot:GetAbilityByName( "ability_thdots_patchouli_water" );
	abilitywood = npcBot:GetAbilityByName( "ability_thdots_patchouli_wood" );
	abilitymetal = npcBot:GetAbilityByName( "ability_thdots_patchouli_metal" );
	abilityearth = npcBot:GetAbilityByName( "ability_thdots_patchouli_earth" );

	-- Consider using each ability
	cast01Desire, cast01Location = ConsiderAbilityAya01();
	cast02Desire, cast02Target = ConsiderAbilityAya02();
	cast04Desire = ConsiderAbilityAya04();

	if ( cast01Desire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( ability01, cast01Location );
		return;
	end

	if ( cast02Desire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( ability02 , cast02Target);
		return;
	end

	if ( cast04Desire > 0 ) 
	then
		npcBot:Action_UseAbility( ability04 );
		return;
	end

end

----------------------------------------------------------------------------------------------------

function CanCastAya01OnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end

function CanCastAya02OnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function CanCastAya04OnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end

----------------------------------------------------------------------------------------------------

function ConsiderItemStun()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not item_stun:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, nil;
	end;

	-- Get some of its values
	local nCastRange = item_stun:GetCastRange();
	--print(nCastRange)
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange , true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcBot:GetTarget() == npcEnemy and CanCastAya02OnTarget( npcEnemy )  ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
		
		if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
		then
			if ( CanCastAya02OnTarget( npcEnemy ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
		
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
	
end

----------------------------------------------------------------------------------------------------

function ConsiderAbilityAya01()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not ability01:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, nil;
	end;

	-- Get some of its values
	local nRadius = ability01:GetSpecialValueInt( "radius" );
	local nCastRange = ability01:GetCastRange();
	local nDamage = ability01:GetAbilityDamage();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're farming and can kill 3+ creeps with LSA
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM ) then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, nDamage );

		if ( locationAoE.count >= 3 ) then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOTTOM or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOTTOM ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );

		if ( locationAoE.count >= 4 ) 
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
	end

	-- If we're seriously attacking
	if ( npcBot:GetActiveMode() == BOT_MODE_ATTACK and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + nRadius + 200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( CanCastAya01OnTarget( npcEnemy ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end

	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil ) 
		then
			if ( CanCastAya01OnTarget( npcTarget ) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil;
end

----------------------------------------------------------------------------------------------------

function ConsiderAbilityAya04()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not ability04:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end;

	-- If we're seriously retreating, or attack
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT or npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		return BOT_ACTION_DESIRE_MODERATE;
	end

	-- If we're seriously retreating, or attack
	if ( npcBot:GetActiveMode() == BOT_MODE_ATTACK or npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		return BOT_ACTION_DESIRE_MODERATE;
	end

	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

----------------------------------------------------------------------------------------------------

function ConsiderAbilityAya02()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not ability02:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE,nil;
	end;

	-- Get some of its values
	local nCastRange = ability02:GetCastRange();

	-- If we're seriously attacking
	if ( npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange , true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if CanCastAya02OnTarget( npcEnemy ) then
				if ( not npcEnemy:HasModifier("modifier_thdots_aya02_buff") ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				else 
					local mf_index = npcEnemy:GetModifierByName("modifier_thdots_aya02_buff")
					if( npcEnemy:GetModifierRemainingDuration(mf_index) < 4.0 ) then
						return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
					end
				end
			end
		end
	end

	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil ) 
		then
			if ( CanCastAya02OnTarget( npcTarget ) )
			then
				return BOT_ACTION_DESIRE_HIGH,npcTarget;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil;

end


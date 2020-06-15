

local tableItemsToBuy = { 
				"item_broom",
				
				"item_wrench",
				"item_cat_foot",
				"item_wind_amulet",
				"item_recipe_verity",
				
				"item_silver_knife",
				"item_paper_mask",
				"item_cat_foot",
				"item_recipe_ganggenier",
				
				"item_knife",
				"item_scissors",
				"item_recipe_quant",
				"item_wrench",
				"item_recipe_sampan",
				
				"item_recipe_travel_boots",
				
				"item_frog",
				"item_ice_block",
				"item_ice_block",
				"item_recipe_frozen",
				
				"item_god_hand",
				"item_god_hand",
				"item_recipe_loneliness",
				
			};


----------------------------------------------------------------------------------------------------

local need_courier = true;

function ItemPurchaseThink()

	local npcBot = GetBot();

	if ( #tableItemsToBuy == 0 )
	then
		npcBot:SetNextItemPurchaseValue( 0 );
		return;
	end

	local sNextItem = nil;
	if (npcBot:GetPlayerID() == 4 or npcBot:GetPlayerID() == 9) then
		if need_courier then
			sNextItem = "item_courier";
		end
	end
	if (sNextItem == nil ) then
		sNextItem = tableItemsToBuy[1];
	end

	npcBot:SetNextItemPurchaseValue( GetItemCost( sNextItem ) );

	if ( npcBot:GetGold() >= GetItemCost( sNextItem ) )
	then
		print(npcBot:GetPlayerID().."[ItemPurchase] purchasing "..sNextItem)
		npcBot:ActionImmediate_PurchaseItem( sNextItem );
		if (sNextItem == "item_courier") then 
			need_courier = false;
		else 
			table.remove( tableItemsToBuy, 1 );
		end
		print(npcBot:GetPlayerID().."[ItemPurchase] purchased "..sNextItem)
	end

end

----------------------------------------------------------------------------------------------------

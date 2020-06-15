

local tableItemsToBuy = { 
				"item_broom",
				
				"item_candle",
				"item_mushroom",
				"item_swimming_suit",
				"item_recipe_peach",
				
				"item_mushroom",
				"item_mushroom",
				"item_recipe_touhou_banana",
				"item_knife",
				"item_scissors",
				"item_recipe_quant",
				"item_recipe_anchor",
				
				"item_god_hand",
				"item_god_hand",
				"item_recipe_loneliness",
				
				"item_silver_knife",
				"item_paper_mask",
				"item_cat_foot",
				"item_recipe_ganggenier",
				
				"item_recipe_travel_boots",
				
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

local function FindItem(item_name)
    local npcBot = GetBot()
    for i = 0, 8 do
        local item = npcBot:GetItemInSlot(i)
        if (item ~= nil) then
            if (item:GetName() == item_name) then
				return item
            end
        end
    end
    return
end

local tableItemsToBuy = { 
				"item_broom",
				
				"item_candle",
				"item_mushroom",
				"item_swimming_suit",
				"item_recipe_peach",
				
				"item_recipe_travel_boots",
				
				"item_mushroom",
				"item_mushroom",
				"item_recipe_touhou_banana",
				"item_knife",
				"item_scissors",
				"item_recipe_quant",
				"item_recipe_anchor",
				
				"item_silver_knife",
				"item_paper_mask",
				"item_cat_foot",
				"item_recipe_ganggenier",
				
				"item_hammer",
				"item_cherry_branch",
				"item_recipe_smash_stick",
				"item_cookbook",
				"item_magic_guide_book",
				"item_rocket_diagram",
				"item_recipe_pocket_watch",
				"item_recipe_yuetufensuijvren",
				
				"item_god_hand",
				"item_god_hand",
				"item_recipe_loneliness",
				
				"item_frog",
				"item_ice_block",
				"item_ice_block",
				"item_recipe_frozen",
				
			};


----------------------------------------------------------------------------------------------------

local need_courier = true;

function ItemPurchaseThink()

	local npcBot = GetBot();
	local sNextItem = nil;
	
	if ( #tableItemsToBuy == 0 )
	then
		if( FindItem("item_peach") ~= nil ) then
			npcBot:ActionImmediate_SellItem( FindItem("item_peach") )
		end
		npcBot:SetNextItemPurchaseValue( 0 );
		return;
	end

	if (npcBot:GetPlayerID() == 4 or npcBot:GetPlayerID() == 9) then
		if need_courier then
			sNextItem = "item_courier";
		end
	end
	if (sNextItem == nil ) then
		sNextItem = tableItemsToBuy[1];
	end

	if sNextItem == "item_frog" then
		if( FindItem("item_peach") ~= nil ) then
			npcBot:ActionImmediate_SellItem( FindItem("item_peach") )
		end
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

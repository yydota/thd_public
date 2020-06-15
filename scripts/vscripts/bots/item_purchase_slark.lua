
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
				
				"item_mushroom",
				"item_cherry_branch",
				"item_recipe_mushroom_kebab",
				"item_hammer",
				"item_recipe_donation_gem",
				
				"item_tengu_fan",
				"item_tengu_fan",
				"item_recipe_camera",
				
				"item_silver_knife",
				"item_paper_mask",
				"item_cat_foot",
				"item_recipe_ganggenier",
				
				"item_knife",
				"item_scissors",
				"item_recipe_quant",
				"item_wrench",
				"item_recipe_sampan",
				
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

	if ( #tableItemsToBuy == 0 )
	then
		if( FindItem("item_donation_gem") ~= nil ) then
			npcBot:ActionImmediate_SellItem( FindItem("item_donation_gem") )
		end
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

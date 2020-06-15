
    if UtilSilence == nil then
	    UtilSilence = class({})
    end

    function UtilSilence:UnitSilenceTarget( caster,target,sliencetime)
		target:AddNewModifier(caster, nil, "modifier_silence", {duration=sliencetime})
    end
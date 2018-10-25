
set CORE:PART:GETMODULE("kOSProcessor"):BOOTFILENAME to "/boot/boot.ks".

print( CORE:PART:GETMODULE("kOSProcessor"):BOOTFILENAME ).

//for part in ship:PARTSDUBBEDPATTERN("(kOSProcessor)")
//{
//	local partname is part:name.
//	print (partname)
//
//	for modname in part:modules
//	{
//		local module is part:getmodule(modname).
//		
//		for eventname in module:ALLEVENTNAMES
//		{
//			print (modname + " " + eventname)
//		}
//	}
//}
_addon.name = 'Roller'
_addon.version = '5.5'
_addon.author = 'Selindrile, thanks to: Balloon and Lorand - PBW Modified'
_addon.commands = {'roller','roll'}

require('luau')
chat = require('chat')
chars = require('chat.chars')
packets = require('packets')
texts = require('texts')

settings = {}
settings.Roll_ind_1 = 8
settings.Roll_ind_2 = 12
settings.showdisplay = true
settings.displayx = nil
settings.displayy = nil
settings.engaged = false
settings.crooked = true
zonedelay = 6
stealthy = ''
was_stealthy = ''
__bust = false
__XI = false

lastRoll = 0
lastRollCrooked = false
midRoll = false
last_roll_info = {} 

windower.register_event('addon command',function (...)
    cmd = {...}

	 if cmd[1] ~= nil then
		cmd[1] = cmd[1]:lower()
	end
	
	if cmd[2] ~= nil then
		cmd[2] = cmd[2]:lower()
	end
	
	if cmd[1] == nil then
		windower.add_to_chat(7,'No command.')
    else
		if cmd[1] == "help" then
			windower.add_to_chat(7,'To start or stop auto rolling type //roller roll')
			windower.add_to_chat(7,'To set rolls use //roller roll# rollname')
		elseif cmd[1] == "display" then
			if cmd[2] == nil then
				settings.showdisplay = not settings.showdisplay
				
			elseif cmd[2] == 'on' or cmd[2] == 'show' then
				settings.showdisplay = true
				
				windower.add_to_chat(7,'Display On.')
			elseif cmd[2] == 'off' or cmd[2] == 'hide' then
				settings.showdisplay = false
				
				windower.add_to_chat(7,'Display Off.')
			else
				windower.add_to_chat(7,'Not a recognized display subcommand. (Show, Hide)')
			end				
		elseif cmd[1] == "engaged" then
			if cmd[2] == nil then
				settings.engaged = not settings.engaged
				
			elseif cmd[2] == 'on' or cmd[2] == 'true' then
				settings.engaged = true
				
				windower.add_to_chat(7,'Engaged Only: On.')
			elseif cmd[2] == 'off' or cmd[2] == 'false' then
				settings.engaged = false
				
				windower.add_to_chat(7,'Engaged Only: Off.')
			else
				windower.add_to_chat(7,'Not a recognized engaged subcommand. (on, off)')
			end
		elseif cmd[1] == "midroll" and cmd[2] == 'off' then	
			midRoll = false
		elseif cmd[1] == "start" or cmd[1] == "on" then
			zonedelay = 6
			if autoroll == false then
				autoroll = true
				if cmd[2] == 'resume' then
					windower.add_to_chat(7,'Enabling Automatic Rolling - RESUME LAST ROLL')
					if last_roll_info and haveBuff("Double-Up Chance") and hasRollActive() then
						doubleUpHelper(last_roll_info.rollNum,last_roll_info.rollID)
					end
				else
					windower.add_to_chat(7,'Enabling Automatic Rolling.')
				end
			elseif autoroll == true then
				windower.add_to_chat(7,'Automatic Rolling already enabled.')
			end
		elseif cmd[1] == "stop" or cmd[1] == "off" then
			zonedelay = 6
			if autoroll == true then
				autoroll = false
				windower.add_to_chat(7,'Disabling Automatic Rolling.')
			elseif autoroll == false then
				windower.add_to_chat(7,'Automatic Rolling already disabled.')
			end
		elseif cmd[1] == "crooked" then
			if cmd[2] == nil then
				settings.crooked = not settings.crooked
			elseif cmd[2] == 'on' then
				settings.crooked = true
				windower.add_to_chat(7,'Crooked: On.')
			elseif cmd[2] == 'off' then
				settings.crooked = false
				windower.add_to_chat(7,'Crooked: Off.')
			else
				windower.add_to_chat(7,'Not a recognized engaged subcommand. (on, off)')
			end
		elseif cmd[1] == "roll" then
			if cmd[2] == "roll1" then
				windower.chat.input('/ja "'..Rollindex[settings.Roll_ind_1]..'" <me>')
			elseif cmd[2] == "roll2" then
				windower.chat.input('/ja "'..Rollindex[settings.Roll_ind_2]..'" <me>')
			else
				zonedelay = 6
				if autoroll == false then
					autoroll = true
					windower.add_to_chat(7,'Enabling Automatic Rolling.')
				elseif autoroll == true then
					autoroll = false 
					windower.add_to_chat(7,'Disabling Automatic Rolling.')
				end
			end

		elseif cmd[1] == "melee" then
			settings.Roll_ind_1 = 8
			settings.Roll_ind_2 = 12
			windower.add_to_chat(7,'Setting Roll 1 to: '..Rollindex[settings.Roll_ind_1]..'')
			windower.add_to_chat(7,'Setting Roll 2 to: '..Rollindex[settings.Roll_ind_2]..'')
			
			
		elseif cmd[1]:startswith('exp') or cmd[1]:startswith('cap') or cmd[1] == "cp" then
			settings.Roll_ind_1 = 17
			settings.Roll_ind_2 = 19
			windower.add_to_chat(7,'Setting Roll 1 to: '..Rollindex[settings.Roll_ind_1]..'')
			windower.add_to_chat(7,'Setting Roll 2 to: '..Rollindex[settings.Roll_ind_2]..'')
			
			
		elseif cmd[1] == "tp" or cmd[1] == "stp" then
			settings.Roll_ind_1 = 12
			settings.Roll_ind_2 = 1
			windower.add_to_chat(7,'Setting Roll 1 to: '..Rollindex[settings.Roll_ind_1]..'')
			windower.add_to_chat(7,'Setting Roll 2 to: '..Rollindex[settings.Roll_ind_2]..'')
			
			
		elseif cmd[1] == "speed" or cmd[1] == "movespeed" or cmd[1]:startswith('bolt') then
			settings.Roll_ind_1 = 21
			settings.Roll_ind_2 = 21
			windower.add_to_chat(7,'Setting Roll 1 to: '..Rollindex[settings.Roll_ind_1]..'')
			windower.add_to_chat(7,'Setting Roll 2 to: '..Rollindex[settings.Roll_ind_2]..'')
			
			
		elseif cmd[1]:startswith('acc') or cmd[1] == "highacc" then
			settings.Roll_ind_1 = 12
			settings.Roll_ind_2 = 11
			windower.add_to_chat(7,'Setting Roll 1 to: '..Rollindex[settings.Roll_ind_1]..'')
			windower.add_to_chat(7,'Setting Roll 2 to: '..Rollindex[settings.Roll_ind_2]..'')
			
		
		elseif cmd[1] == "ws" or cmd[1] == "wsd" then
			settings.Roll_ind_1 = 8
			settings.Roll_ind_2 = 1
			windower.add_to_chat(7,'Setting Roll 1 to: '..Rollindex[settings.Roll_ind_1]..'')
			windower.add_to_chat(7,'Setting Roll 2 to: '..Rollindex[settings.Roll_ind_2]..'')
			
		
		elseif cmd[1] == "nuke" or cmd[1] == "burst" or cmd[1] == "matk" or cmd[1]:startswith('mag')  then
			settings.Roll_ind_1 = 4
			settings.Roll_ind_2 = 15
			windower.add_to_chat(7,'Setting Roll 1 to: '..Rollindex[settings.Roll_ind_1]..'')
			windower.add_to_chat(7,'Setting Roll 2 to: '..Rollindex[settings.Roll_ind_2]..'')
			
		
		elseif cmd[1] == "pet" or cmd[1]:startswith("petphy") then
			settings.Roll_ind_1 = 9
			settings.Roll_ind_2 = 14
			windower.add_to_chat(7,'Setting Roll 1 to: '..Rollindex[settings.Roll_ind_1]..'')
			windower.add_to_chat(7,'Setting Roll 2 to: '..Rollindex[settings.Roll_ind_2]..'')
			
		
		elseif cmd[1] == "petnuke" or cmd[1]:startswith('petma') then
			settings.Roll_ind_1 = 18
			settings.Roll_ind_2 = 28
			windower.add_to_chat(7,'Setting Roll 1 to: '..Rollindex[settings.Roll_ind_1]..'')
			windower.add_to_chat(7,'Setting Roll 2 to: '..Rollindex[settings.Roll_ind_2]..'')
			
		elseif cmd[1] == "mbozespecial" or cmd[1]:startswith('mboze') then
			settings.Roll_ind_1 = 5
			settings.Roll_ind_2 = 22
			windower.add_to_chat(7,'Setting Roll 1 to: '..Rollindex[settings.Roll_ind_1]..'')
			windower.add_to_chat(7,'Setting Roll 2 to: '..Rollindex[settings.Roll_ind_2]..'')
			
		elseif cmd[1] == "roll1" then
			local rollchange = false
			if cmd[2] == nil then windower.add_to_chat(7,'Roll 1: '..Rollindex[settings.Roll_ind_1]..'') return
			elseif cmd[2]:startswith("warlock") or cmd[2]:startswith("macc") or cmd[2]:startswith("magic ac") or cmd[2]:startswith("rdm") then settings.Roll_ind_1 = 5 rollchange = true
			elseif cmd[2]:startswith("fight") or cmd[2]:startswith("double") or cmd[2]:startswith("dbl") or cmd[2]:startswith("war") then settings.Roll_ind_1 = 1 rollchange = true
			elseif cmd[2]:startswith("monk") or cmd[2]:startswith("subtle") or cmd[2]:startswith("mnk") then settings.Roll_ind_1 = 2 rollchange = true
			elseif cmd[2]:startswith("heal") or cmd[2]:startswith("cure") or cmd[2]:startswith("whm") then settings.Roll_ind_1 = 3 rollchange = true
			elseif cmd[2]:startswith("wizard") or cmd[2]:startswith("matk") or cmd[2]:startswith("magic at") or cmd[2]:startswith("blm") then settings.Roll_ind_1 = 4 rollchange = true
			elseif cmd[2]:startswith("rogue") or cmd[2]:startswith("crit") or cmd[2]:startswith("thf") then settings.Roll_ind_1 = 6 rollchange = true
			elseif cmd[2]:startswith("gallant") or cmd[2]:startswith("def") or cmd[2]:startswith("pld") then settings.Roll_ind_1 = 7 rollchange = true
			elseif cmd[2]:startswith("chaos") or cmd[2]:startswith("attack") or cmd[2]:startswith("atk") or cmd[2]:startswith("drk") then settings.Roll_ind_1 = 8 rollchange = true
			elseif cmd[2]:startswith("beast") or cmd[2]:startswith("pet at") or cmd[2]:startswith("bst") then settings.Roll_ind_1 = 9 rollchange = true
			elseif cmd[2]:startswith("choral") or cmd[2]:startswith("inter") or cmd[2]:startswith("spell inter") or cmd[2]:startswith("brd") then settings.Roll_ind_1 = 10 rollchange = true
			elseif cmd[2]:startswith("hunt") or cmd[2]:startswith("acc") or  cmd[2]:startswith("rng") then settings.Roll_ind_1 = 11 rollchange = true
			elseif cmd[2]:startswith("sam") or cmd[2]:startswith("stp") or cmd[2]:startswith("store") then settings.Roll_ind_1 = 12 rollchange = true
			elseif cmd[2]:startswith("nin") or cmd[2]:startswith("eva") then settings.Roll_ind_1 = 13 rollchange = true
			elseif cmd[2]:startswith("drach") or cmd[2]:startswith("pet ac") or cmd[2]:startswith("drg") then settings.Roll_ind_1 = 14 rollchange = true
			elseif cmd[2]:startswith("evoke") or cmd[2]:startswith("refresh") or cmd[2]:startswith("smn") then settings.Roll_ind_1 = 15 rollchange = true
			elseif cmd[2]:startswith("magus") or cmd[2]:startswith("mdb") or cmd[2]:startswith("magic d") or cmd[2]:startswith("blu") then settings.Roll_ind_1 = 16 rollchange = true
			elseif cmd[2]:startswith("cor") or cmd[2]:startswith("exp") then settings.Roll_ind_1 = 17 rollchange = true
			elseif cmd[2]:startswith("pup") or cmd[2]:startswith("pet m") then settings.Roll_ind_1 = 18 rollchange = true
			elseif cmd[2]:startswith("dance") or cmd[2]:startswith("regen") or cmd[2]:startswith("dnc") then settings.Roll_ind_1 = 19 rollchange = true
			elseif cmd[2]:startswith("sch") or cmd[2]:startswith("conserve m") then settings.Roll_ind_1 = 20 rollchange = true
			elseif cmd[2]:startswith("bolt") or cmd[2]:startswith("move") or cmd[2]:startswith("flee") or cmd[2]:startswith("speed") then settings.Roll_ind_1 = 21 rollchange = true
			elseif cmd[2]:startswith("cast") or cmd[2]:startswith("fast") or cmd[2]:startswith("fc") then settings.Roll_ind_1 = 22 rollchange = true
			elseif cmd[2]:startswith("course") or cmd[2]:startswith("snap") then settings.Roll_ind_1 = 23 rollchange = true
			elseif cmd[2]:startswith("blitz") or cmd[2]:startswith("delay") then settings.Roll_ind_1 = 24 rollchange = true
			elseif cmd[2]:startswith("tact") or cmd[2]:startswith("regain") then settings.Roll_ind_1 = 25 rollchange = true
			elseif cmd[2]:startswith("all") or cmd[2]:startswith("skillchain") then settings.Roll_ind_1 = 26 rollchange = true
			elseif cmd[2]:startswith("miser") or cmd[2]:startswith("save tp") or cmd[2]:startswith("conserve t") then settings.Roll_ind_1 = 27 rollchange = true
			elseif cmd[2]:startswith("companion") or cmd[2]:startswith("pet r") then settings.Roll_ind_1 = 28 rollchange = true
			elseif cmd[2]:startswith("avenge") or cmd[2]:startswith("counter") then settings.Roll_ind_1 = 29 rollchange = true
			elseif cmd[2]:startswith("natural") or cmd[2]:startswith("enhance") or cmd[2]:startswith("duration") then settings.Roll_ind_1 = 30 rollchange = true
			elseif cmd[2]:startswith("run") or cmd[2]:startswith("meva") or cmd[2]:startswith("magic e") then settings.Roll_ind_1 = 31 rollchange = true
			end
			
			if rollchange == true then
				windower.add_to_chat(7,'Setting Roll 1 to: '..Rollindex[settings.Roll_ind_1]..'')
			else
				windower.add_to_chat(7,'Invalid roll name, Roll 1 remains: '..Rollindex[settings.Roll_ind_1]..'')
			end

		elseif cmd[1] == "roll2" then
			local rollchange = false
			if cmd[2] == nil then windower.add_to_chat(7,'Roll 1: '..Rollindex[settings.Roll_ind_2]..'') return
			elseif cmd[2]:startswith("warlock") or cmd[2]:startswith("macc") or cmd[2]:startswith("magic ac") or cmd[2]:startswith("rdm") then settings.Roll_ind_2 = 5 rollchange = true
			elseif cmd[2]:startswith("fight") or cmd[2]:startswith("double") or cmd[2]:startswith("dbl") or cmd[2]:startswith("war") then settings.Roll_ind_2 = 1 rollchange = true
			elseif cmd[2]:startswith("monk") or cmd[2]:startswith("subtle") or cmd[2]:startswith("mnk") then settings.Roll_ind_2 = 2 rollchange = true
			elseif cmd[2]:startswith("heal") or cmd[2]:startswith("cure") or cmd[2]:startswith("whm") then settings.Roll_ind_2 = 3 rollchange = true
			elseif cmd[2]:startswith("wizard") or cmd[2]:startswith("matk") or cmd[2]:startswith("magic at") or cmd[2]:startswith("blm") then settings.Roll_ind_2 = 4 rollchange = true
			elseif cmd[2]:startswith("rogue") or cmd[2]:startswith("crit") or cmd[2]:startswith("thf") then settings.Roll_ind_2 = 6 rollchange = true
			elseif cmd[2]:startswith("gallant") or cmd[2]:startswith("def") or cmd[2]:startswith("pld") then settings.Roll_ind_2 = 7 rollchange = true
			elseif cmd[2]:startswith("chaos") or cmd[2]:startswith("attack") or cmd[2]:startswith("atk") or cmd[2]:startswith("drk") then settings.Roll_ind_2 = 8 rollchange = true
			elseif cmd[2]:startswith("beast") or cmd[2]:startswith("pet at") or cmd[2]:startswith("bst") then settings.Roll_ind_2 = 9 rollchange = true
			elseif cmd[2]:startswith("choral") or cmd[2]:startswith("inter") or cmd[2]:startswith("spell inter") or cmd[2]:startswith("brd") then settings.Roll_ind_2 = 10 rollchange = true
			elseif cmd[2]:startswith("hunt") or cmd[2]:startswith("acc") or  cmd[2]:startswith("rng") then settings.Roll_ind_2 = 11 rollchange = true
			elseif cmd[2]:startswith("sam") or cmd[2]:startswith("stp") or cmd[2]:startswith("store") then settings.Roll_ind_2 = 12 rollchange = true
			elseif cmd[2]:startswith("nin") or cmd[2]:startswith("eva") then settings.Roll_ind_2 = 13 rollchange = true
			elseif cmd[2]:startswith("drach") or cmd[2]:startswith("pet ac") or cmd[2]:startswith("drg") then settings.Roll_ind_2 = 14 rollchange = true
			elseif cmd[2]:startswith("evoke") or cmd[2]:startswith("refresh") or cmd[2]:startswith("smn") then settings.Roll_ind_2 = 15 rollchange = true
			elseif cmd[2]:startswith("magus") or cmd[2]:startswith("mdb") or cmd[2]:startswith("magic d") or cmd[2]:startswith("blu") then settings.Roll_ind_2 = 16 rollchange = true
			elseif cmd[2]:startswith("cor") or cmd[2]:startswith("exp") then settings.Roll_ind_2 = 17 rollchange = true
			elseif cmd[2]:startswith("pup") or cmd[2]:startswith("pet m") then settings.Roll_ind_2 = 18 rollchange = true
			elseif cmd[2]:startswith("dance") or cmd[2]:startswith("regen") or cmd[2]:startswith("dnc") then settings.Roll_ind_2 = 19 rollchange = true
			elseif cmd[2]:startswith("sch") or cmd[2]:startswith("conserve m") then settings.Roll_ind_2 = 20 rollchange = true
			elseif cmd[2]:startswith("bolt") or cmd[2]:startswith("move") or cmd[2]:startswith("flee") or cmd[2]:startswith("speed") then settings.Roll_ind_2 = 21 rollchange = true
			elseif cmd[2]:startswith("cast") or cmd[2]:startswith("fast") or cmd[2]:startswith("fc") then settings.Roll_ind_2 = 22 rollchange = true
			elseif cmd[2]:startswith("course") or cmd[2]:startswith("snap") then settings.Roll_ind_2 = 23 rollchange = true
			elseif cmd[2]:startswith("blitz") or cmd[2]:startswith("delay") then settings.Roll_ind_2 = 24 rollchange = true
			elseif cmd[2]:startswith("tact") or cmd[2]:startswith("regain") then settings.Roll_ind_2 = 25 rollchange = true
			elseif cmd[2]:startswith("all") or cmd[2]:startswith("skillchain") then settings.Roll_ind_2 = 26 rollchange = true
			elseif cmd[2]:startswith("miser") or cmd[2]:startswith("save tp") or cmd[2]:startswith("conserve t") then settings.Roll_ind_2 = 27 rollchange = true
			elseif cmd[2]:startswith("companion") or cmd[2]:startswith("pet r") then settings.Roll_ind_2 = 28 rollchange = true
			elseif cmd[2]:startswith("avenge") or cmd[2]:startswith("counter") then settings.Roll_ind_2 = 29 rollchange = true
			elseif cmd[2]:startswith("natural") or cmd[2]:startswith("enhance") or cmd[2]:startswith("duration") then settings.Roll_ind_2 = 30 rollchange = true
			elseif cmd[2]:startswith("run") or cmd[2]:startswith("meva") or cmd[2]:startswith("magic e") then settings.Roll_ind_2 = 31 rollchange = true
			end
			
			if rollchange == true then
				windower.add_to_chat(7,'Setting Roll 2 to: '..Rollindex[settings.Roll_ind_2]..'')
			else
				windower.add_to_chat(7,'Invalid roll name, Roll 2 remains: '..Rollindex[settings.Roll_ind_2]..'')
			end
		 elseif cmd[1] == "bust" then
			if cmd[2] and cmd[2] == 'off' then
				__bust = false
				windower.add_to_chat(7,'Turning OFF Bust for rolls.')
			elseif cmd[2] and cmd[2] == 'on' then
				__bust = true
				
				windower.add_to_chat(7,'Using Bust for rolls.')
			end
		 elseif cmd[1] == "xi" then
			if cmd[2] and cmd[2] == 'off' then
				__XI = false
				windower.add_to_chat(7,'Turning OFF XI spam for rolls.')
			elseif cmd[2] and cmd[2] == 'on' then
				__XI = true
				windower.add_to_chat(7,'Using XI spam for rolls.')
			end
         end
        
    end
	
	update_displaybox()
end)

windower.register_event('load', function()

	autoroll = false

	buffId = S{309} + S(res.buffs:english(string.endswith-{' Roll'})):map(table.get-{'en'})
	
    Rollindex = {'Fighter\'s Roll','Monk\'s Roll','Healer\'s Roll','Wizard\'s Roll','Warlock\'s Roll','Rogue\'s Roll','Gallant\'s Roll','Chaos Roll','Beast Roll',
				 'Choral Roll','Hunter\'s Roll','Samurai Roll','Ninja Roll','Drachen Roll','Evoker\'s Roll','Magus\'s Roll','Corsair\'s Roll','Puppet Roll',
				 'Dancer\'s Roll','Scholar\'s Roll','Bolter\'s Roll','Caster\'s Roll','Courser\'s Roll','Blitzer\'s Roll','Tactician\'s Roll','Allies\' Roll',
				 'Miser\'s Roll','Companion\'s Roll','Avenger\'s Roll','Naturalist\'s Roll','Runeist\'s Roll'}
				 
    local rollInfoTemp = {
        -- Okay, this goes 1-11 boost, Bust effect, Effect, Lucky, +1 Phantom Roll Effect, Bonus Equipment and Effect,
        ['Chaos'] = {6,8,9,25,11,13,16,3,17,19,31,"-4", '% Attack!', 4, 8},
        ['Fighter\'s'] = {2,2,3,4,12,5,6,7,1,9,18,'-4','% Double-Attack!', 5, 9},
        ['Wizard\'s'] = {4,6,8,10,25,12,14,17,2,20,30, "-10", ' MAB', 5, 9},
        ['Evoker\'s'] = {1,1,1,1,3,2,2,2,1,3,4,'-1', ' Refresh!',5, 9},
        ['Rogue\'s'] = {2,2,3,4,12,5,6,6,1,8,14,'-6', '% Critical Hit Rate!', 5, 9},
        ['Corsair\'s'] = {10, 11, 11, 12, 20, 13, 15, 16, 8, 17, 24, '-6', '% Experience Bonus',5, 9},
        ['Hunter\'s'] = {10,13,15,40,18,20,25,5,27,30,50,'-?', ' Accuracy Bonus',4, 8},
        ['Magus\'s'] = {5,20,6,8,9,3,10,13,14,15,25,'-8',' Magic Defense Bonus',2, 6},
        ['Healer\'s'] = {3,4,12,5,6,7,1,8,9,10,16,'-4','% Cure Potency',3, 7},
        ['Drachen'] = {10,13,15,40,18,20,25,5,28,30,50,'-8',' Pet: Accuracy Bonus',4, 8},
        ['Choral'] = {8,42,11,15,19,4,23,27,31,35,50,'+25', '- Spell Interruption Rate',2, 6},
        ['Monk\'s'] = {8,10,32,12,14,15,4,20,22,24,40,'-?', ' Subtle Blow', 3, 7},
        ['Beast'] = {6,8,9,25,11,13,16,3,17,19,31,'-10', '% Pet: Attack Bonus',4, 8},
        ['Samurai'] = {7,32,10,12,14,4,16,20,22,24,40,'-10',' Store TP Bonus',2, 6},
        ['Warlock\'s'] = {2,3,4,12,5,6,7,1,8,9,15,'-5',' Magic Accuracy Bonus',4, 8},
        ['Puppet'] = {5,8,35,11,14,18,2,22,26,30,40,'-8',' Pet: Magic Attack Bonus',3, 7},
        ['Gallant\'s'] = {4,5,15,6,7,8,3,9,10,11,20,'-10','% Defense Bonus', 3, 7},
        ['Dancer\'s'] = {3,4,12,5,6,7,1,8,9,10,16,'-4',' Regen',3, 7},
        ['Bolter\'s'] = {0.3,0.3,0.8,0.4,0.4,0.5,0.5,0.6,0.2,0.7,1.0,'-8','% Movement Speed',3, 9},
        ['Caster\'s'] = {6,15,7,8,9,10,5,11,12,13,20,'-10','% Fast Cast',2, 7},
        ['Tactician\'s'] = {10,10,10,10,30,10,10,0,20,20,40,'-10',' Regain',5, 8},
        ['Miser\'s'] = {30,50,70,90,200,110,20,130,150,170,250,'0',' Save TP',5, 7},
        ['Ninja'] = {4,5,5,14,6,7,9,2,10,11,18,'-10',' Evasion Bonus',4, 8},
        ['Scholar\'s'] = {'?','?','?','?','?','?','?','?','?','?','?','?',' Conserve MP',2, 6},
        ['Allies\''] = {6,7,17,9,11,13,15,17,17,5,17,'?','% Skillchain Damage',3, 10},
        ['Companion\'s'] = {{4,20},{20, 50},{6,20},{8, 20},{10,30},{12,30},{14,30},{16,40},{18, 40}, {3,10},{30, 70},'-?',' Pet: Regen/Regain',2, 10},
        ['Avenger\'s'] = {'?','?','?','?','?','?','?','?','?','?','?','?',' Counter Rate',4, 8},
        ['Blitzer\'s'] = {2,3.4,4.5,11.3,5.3,6.4,7.2,8.3,1.5,10.2,12.1,'-?', '% Attack delay reduction',4, 9},
        ['Courser\'s'] = {'?','?','?','?','?','?','?','?','?','?','?','?',' Snapshot',3, 9},
        ['Runeist\'s'] = {'?','?','?','?','?','?','?','?','?','?','?','?',' Magic Evasion',4, 8},
        ['Naturalist\'s'] = {'?','?','?','?','?','?','?','?','?','?','?','?',' Enhancing Magic Duration',3, 7}
    }

    rollInfo = {}
    for key, val in pairs(rollInfoTemp) do
        rollInfo[res.job_abilities:with('english', key .. ' Roll').id] = {key, unpack(val)}
    end
    
	if settings.showdisplay then
		create_display(settings)
	end	
end)

function waitAndRollDoubleUp()
	coroutine.sleep(1.0)
    local abil_recasts = windower.ffxi.get_ability_recasts()
    -- Wait for Double-Up to be ready
    while abil_recasts[194] ~= 0 do
        coroutine.sleep(0.5)
        abil_recasts = windower.ffxi.get_ability_recasts()
    end
	coroutine.sleep(1.7)
	abil_recasts = windower.ffxi.get_ability_recasts()
    -- Once ready, perform Double-Up
    while abil_recasts[194] == 0 and hasRollActive() do
        windower.send_command('input /ja "Double-Up" <me>')
        coroutine.sleep(2.5)
        abil_recasts = windower.ffxi.get_ability_recasts()
    end
end

function snakeEye()
	local abil_recasts = windower.ffxi.get_ability_recasts()
	while abil_recasts[197] == 0 do
		windower.send_command('input /ja "Snake Eye" <me>')
		coroutine.sleep(2.5)
		abil_recasts = windower.ffxi.get_ability_recasts()
	end
end

windower.register_event('action', function(act)

    if act.category == 6 and table.containskey(rollInfo, act.param) then

        rollActor = act.actor_id
        local rollID = act.param
		if rollID == 177 then return end
        local rollNum = act.targets[1].actions[1].param
		local player = windower.ffxi.get_player()
		-- Store the last roll info, regardless of autoroll state
        last_roll_info = { rollID = rollID, rollNum = rollNum }

		if act.actor_id == player.id then
			if act.targets[1].actions[1].message ~= 424 then
				lastRollCrooked = false
			end
			if (not __bust and rollNum == rollInfo[rollID][15]) or rollNum == 11 then -- If lucky or 11 then stop rolling
				windower.add_to_chat(7,'Lucky or XI - Stop rolling.')
				lastRoll = rollNum
				midRoll = false
				return
			end

			if not autoroll or haveBuff('amnesia') or haveBuff('impairment') then
				if rollID ~= 118 then return end -- Only return if NOT rollID 118
			end

			doubleUpHelper(rollNum,rollID)
			
		end
	end
end)

function doubleUpHelper(rollNum,rollID)
	local player = windower.ffxi.get_player()
	if player.main_job == 'COR' then
		local abil_recasts = windower.ffxi.get_ability_recasts()
		local available_ja = S(windower.ffxi.get_abilities().job_abilities)
		
		if rollID ~= 118 then
			if __bust and available_ja:contains(178) and abil_recasts[198] == 0 and rollNum < 10 and rollNum ~= rollInfo[rollID][15] then  -- and not lastRollCrooked
				windower.add_to_chat(7,'Bust function is on - Try for 11.')
				midRoll = true
				waitAndRollDoubleUp()
			-- Snake eye to get XI
			elseif available_ja:contains(177) and abil_recasts[197] == 0 and (rollNum == 10) then  -- If Snake Eye is up.
				windower.add_to_chat(7,'10, doing Snake Eye to get 11')
				midRoll = true
				snakeEye()
				waitAndRollDoubleUp()
			-- 1 to lucky use Snake Eye
			elseif available_ja:contains(177) and abil_recasts[197] == 0 and rollNum == (rollInfo[rollID][15] - 1) then
				windower.add_to_chat(7,'Close to lucky [1]')
				midRoll = true
				snakeEye()
				waitAndRollDoubleUp()
			-- Unlucky, use Snake Eye to get out of it.
			elseif available_ja:contains(177) and abil_recasts[197] == 0 and lastRoll ~= 11 and rollNum >= 6 and rollNum == rollInfo[rollID][16] then
				windower.add_to_chat(7,'Unlucky, doing Snake Eye to get out of it.')
				midRoll = true
				snakeEye()
				waitAndRollDoubleUp()
			-- Roll 11 if last roll 11
			elseif __XI and lastRoll == 11 then -- and not lastRollCrooked
				windower.add_to_chat(7,'XI function is on - Get both rolls 11.')
				midRoll = true
				waitAndRollDoubleUp()
			-- Less than 6 so roll again.
			elseif rollNum < 6 and rollNum ~= rollInfo[rollID][15] then
				windower.add_to_chat(7,'Less than 6 and not lucky, re-roll')
				midRoll = true
				waitAndRollDoubleUp()
			else
				midRoll = false
				lastRoll = rollNum
			end
		else -- Bolters
			if rollNum <= 2 then
				midRoll = true
				waitAndRollDoubleUp()
			end
		end
	elseif rollNum < 6 then -- COR subjob.
		midRoll = true
		waitAndRollDoubleUp()
	end
end

function haveBuff(...)
	local args = S{...}:map(string.lower)
	local player = windower.ffxi.get_player()
	if (player ~= nil) and (player.buffs ~= nil) then
		for _,bid in pairs(player.buffs) do
			local buff = res.buffs[bid]
			if args:contains(buff.en:lower()) then
				return true
			end
		end
	end
	return false
end

function hasRollActive()
    local player = windower.ffxi.get_player()
    if (player ~= nil) and (player.buffs ~= nil) then
        for _, bid in pairs(player.buffs) do
            if (bid >= 310 and bid <= 339) or (bid == 600) then
                return true
            end
        end
    end
    return false
end

Cities = S{
    "Ru'Lude Gardens",
    "Upper Jeuno",
    "Lower Jeuno",
    "Port Jeuno",
    "Port Windurst",
    "Windurst Waters",
    "Windurst Woods",
    "Windurst Walls",
    "Heavens Tower",
    "Port San d'Oria",
    "Northern San d'Oria",
    "Southern San d'Oria",
	"Chateau d'Oraguille",
    "Port Bastok",
    "Bastok Markets",
    "Bastok Mines",
    "Metalworks",
    "Aht Urhgan Whitegate",
	"The Colosseum",
    "Tavanazian Safehold",
    "Nashmau",
    "Selbina",
    "Mhaura",
	"Rabao",
    "Norg",
    "Kazham",
    "Eastern Adoulin",
    "Western Adoulin",
	"Celennia Memorial Library",
	"Mog Garden",
	"Leafallia"
}

function doRoll()
	coroutine.sleep(1.5)
	--if Cities:contains(res.zones[windower.ffxi.get_info().zone].english) then return end
	if not autoroll or haveBuff('amnesia') or haveBuff('impairment') or midRoll then return end
	stealthy = false
	if not (stealthy == was_stealthy) then update_displaybox() end
	was_stealthy = stealthy
	if stealthy then return end
	local player = windower.ffxi.get_player()
	if not (player.main_job == 'COR' or player.sub_job == 'COR') then return end
	local status = res.statuses[windower.ffxi.get_player().status].english
	if not (((status == 'Idle') and not settings.engaged) or status == 'Engaged') then return end
	local abil_recasts = windower.ffxi.get_ability_recasts()
	local available_ja = S(windower.ffxi.get_abilities().job_abilities)

	if __bust and player.main_job == 'COR'
		and abil_recasts[198] and abil_recasts[198] > 0 -- Fold
		--and abil_recasts[197] and abil_recasts[197] > 0 -- Snake Eye
		--and abil_recasts[193] == 0 -- Phantom Roll
		and abil_recasts[194] == 0 -- Double Up
		and abil_recasts[196] and abil_recasts[196] == 0 then -- Random Deal
			windower.add_to_chat(7,'Fold used - Random Deal')
			windower.send_command('input /ja "Random Deal" <me>')
			return 
	end
	
	-- If snake eye used to get 11 on last roll, random deal.
	if __bust and lastRoll == 11 and player.main_job == 'COR' and abil_recasts[197] > 0 and abil_recasts[196] and abil_recasts[196] == 0 then
		windower.add_to_chat(7,'XI Last roll, Snake Eye used - Random Deal')
		windower.send_command('input /ja "Random Deal" <me>')
		return
	end
	
	if player.main_job == 'COR' and haveBuff('Bust') and available_ja:contains(178) and abil_recasts[198] and abil_recasts[198] == 0 then 
		windower.add_to_chat(7,'Bust - Use Fold')
		windower.send_command('wait 1.5; input /ja "Fold" <me>') return end
	if abil_recasts[193] > 0 then return end

	if not haveBuff(Rollindex[settings.Roll_ind_1]) and not haveBuff(Rollindex[settings.Roll_ind_2]) then
		lastRoll = 0
		lastRollCrooked = false
	end
	
	if not haveBuff(Rollindex[settings.Roll_ind_1]) then
		if player.main_job == 'COR' and settings.crooked and player.main_job_level > 94 and abil_recasts[96] == 0 then 
			windower.send_command('input /ja "Crooked Cards" <me>; wait 1.5; input /ja "'..Rollindex[settings.Roll_ind_1]..'" <me>')
		else
			windower.send_command('input /ja "'..Rollindex[settings.Roll_ind_1]..'" <me>')
		end
		
	elseif player.main_job == 'COR' and not haveBuff(Rollindex[settings.Roll_ind_2]) and not haveBuff('Bust') then
		windower.send_command('input /ja "'..Rollindex[settings.Roll_ind_2]..'" <me>')
	end

end

windower.register_event('lose buff', function(buff_id)
	if buff_id == 601 then
		local abil_recasts = windower.ffxi.get_ability_recasts()

		if abil_recasts[193] > 40 and haveBuff("Double-Up Chance") then
			lastRollCrooked = true
		end
	elseif buff_id == 308 then
		midRoll = false
	end
end)


windower.register_event('zone change', function()
	zonedelay = 0
	autoroll = false
	lastRoll = 0
	lastRollCrooked = false
	update_displaybox()
end)

windower.register_event('job change', function()
	zonedelay = 0
	autoroll = false
	lastRoll = 0
	lastRollCrooked = false
	update_displaybox()
end)

function create_display(settings)
    if displayBox then displayBox:destroy() end

    local windowersettings = windower.get_windower_settings()
	local x,y
	
	if settings.displayx and settings.displayy then
		x = settings.displayx
		y = settings.displayy
	elseif windowersettings["ui_x_res"] == 1920 and windowersettings["ui_y_res"] == 1080 then
		x,y = windowersettings["ui_x_res"]-505, windowersettings["ui_y_res"]-18 -- -285, -18
	else
		x,y = windowersettings["ui_x_res"]-1020, 0 --windowersettings["ui_y_res"]- -- -285, -18
	end
	
    displayBox = texts.new()
    displayBox:pos(x,y)
    displayBox:font('Arial')--Arial
    displayBox:size(12)
    displayBox:bold(true)
    displayBox:bg_alpha(0)--128
    displayBox:right_justified(false)
    displayBox:stroke_width(2)
    displayBox:stroke_transparency(192)

    update_displaybox(displayBox)
end

function update_displaybox()
	local player = windower.ffxi.get_player()
	if not player then return end
	if not settings.showdisplay or not (player.main_job == 'COR' or player.sub_job == 'COR') then
		if displayBox then displayBox:hide() end
		return		
	end
	
    -- Define colors for text in the display
    local clr = {
        h='\\cs(255,192,0)', -- Yellow for active booleans and non-default modals
		w='\\cs(255,255,255)', -- White for labels and default modals
        n='\\cs(192,192,192)', -- White for labels and default modals
        s='\\cs(96,96,96)', -- Gray for inactive booleans
		g='\\cs(0,255,0)',     -- Green for "On"
        r='\\cs(255,0,0)',      -- Red for "Off"
    }

    local info = {}
    local orig = {}
    local spc = '   '

    -- Define labels for each modal state
    local labels = {

    }

    displayBox:clear()

 	displayBox:append("Roll 1: "..Rollindex[settings.Roll_ind_1].."   ")
	if windower.ffxi.get_player().main_job == 'COR' and settings.Roll_ind_1 ~= settings.Roll_ind_2 then
		displayBox:append("Roll 2: "..Rollindex[settings.Roll_ind_2].."   ")
	end
	displayBox:append("Autoroll: ")
	if autoroll == true then
		displayBox:append(clr.g .. "On\\cr")
	else
		displayBox:append(clr.r .. "Off\\cr")
	end

	if settings.engaged then
		displayBox:append("  Engaged")
	end
	
	displayBox:append("  Bust: ")
	if __bust then
		displayBox:append(clr.g .. "On\\cr")
	elseif __bust == false then
		displayBox:append(clr.r .. "Off\\cr")
	end
	
	displayBox:append("  XI: ")
	if __XI then
		displayBox:append(clr.g .. "On\\cr")
	elseif __XI == false then
		displayBox:append(clr.r .. "Off\\cr")
	end
	
    -- Update and display current info
    displayBox:update(info)
    displayBox:show()

end

windower.register_event('outgoing chunk', function(id, data)
    if id == 0x00D and displayBox then
        displayBox:hide()
    end
end)

windower.register_event('incoming chunk', function(id, data)
    if id == 0x00A and displayBox then
        displayBox:show()
    end
end)

doRoll:loop(3)
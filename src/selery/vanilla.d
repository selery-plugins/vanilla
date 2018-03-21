/*
 * Copyright (c) 2017-2018 sel-project
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */
module selery.vanilla;

import std.algorithm : sort, clamp, min, filter;
import std.conv : to;
import std.math : ceil;
import std.random : uniform;
import std.string : join, toLower, startsWith;
import std.traits : hasUDA, getUDAs, Parameters;
import std.typetuple : TypeTuple;

import sel.format : Format, unformat;

import selery.about : Software;
import selery.command.command : Command;
import selery.command.util : CommandSender, WorldCommandSender, PocketType, SingleEnum, SnakeCaseEnum, Ranged, Position, Target;
import selery.config : Config, Gamemode, Difficulty, Dimension;
import selery.effect : Effects;
import selery.enchantment : Enchantments;
import selery.entity.entity : Entity;
import selery.lang : Translation, Translatable;
import selery.node.plugin;
import selery.node.server : isServerRunning, NodeServer, ServerCommandSender;
import selery.player.bedrock : BedrockPlayer;
import selery.player.java : JavaPlayer;
import selery.player.player : PlayerInfo, Player, PermissionLevel;
import selery.plugin : Description, permission, hidden, unimplemented;
import selery.util.messages : Messages;
import selery.world.group : GroupInfo;
import selery.world.world : WorldInfo, Time;

enum vanilla;
enum op;

struct aliases {

	string[] aliases;

	this(string[] aliases...) {
		this.aliases = aliases;
	}

}

/**
 * Supported vanilla commands:
 * [ ] clear
 * [ ] clone
 * [ ] defaultgamemode
 * [x] deop
 * [ ] difficulty
 * [ ] effect
 * [ ] enchant
 * [ ] execute
 * [ ] fill
 * [x] gamemode
 * [ ] gamerule
 * [ ] give
 * [x] help
 * [x] kick
 * [ ] kill
 * [x] list
 * [ ] locate
 * [x] me
 * [x] op
 * [ ] playsound
 * [ ] replaceitem
 * [x] say
 * [ ] setblock
 * [x] setmaxplayers
 * [ ] setworldspawn
 * [ ] spawnpoint
 * [ ] spreadplayers
 * [x] stop
 * [ ] stopsound
 * [ ] summon
 * [x] tell
 * [ ] testfor
 * [ ] testforblock
 * [ ] testforblocks
 * [ ] time
 * [ ] title
 * [x] toggledownfall
 * [ ] tp (teleport)
 * [x] transferserver
 * [x] weather
 * 
 * Supported multiplayer commands:
 * [ ] ban
 * [ ] ban-ip
 * [ ] banlist
 * [ ] pardon
 * [x] stop
 * [ ] whitelist
 */
class Main : NodePlugin {

	// clear

	@command("clear") @op clear0(Player sender) {
		this.clear1(sender, [sender]);
	}

	@unimplemented @command("clear") clear1(WorldCommandSender sender, Player[] target) {}

	@unimplemented @command("clear") clear2(WorldCommandSender sender, Player[] target, string itemName) {}

	// clone

	enum MaskMode { masked, replace }

	enum CloneMode { force, move, normal }
	
	@unimplemented @command("clone") @op clone0(WorldCommandSender sender, Position begin, Position end, Position destination, MaskMode maskMode=MaskMode.replace, CloneMode cloneMode=CloneMode.normal) {}
	
	@unimplemented @command("clone") clone1(WorldCommandSender sender, Position begin, Position end, Position destination, SingleEnum!"filtered" maskMode, CloneMode cloneMode, string tileName) {}

	// defaultgamemode

	@unimplemented @command("defaultgamemode") @op defaultgamemode0(WorldCommandSender sender, Gamemode gamemode) {}

	// deop

	@command("deop") @op deop0(WorldCommandSender sender, Player player) {
		if(player.permissionLevel <= PermissionLevel.operator) {
			if(player.operator) {
				player.operator = false;
				player.sendMessage(Translation(Messages.deop.message));
			}
			sender.sendMessage(Translation(Messages.deop.success, player.displayName));
		} else {
			sender.sendMessage(Translation(Messages.deop.failed, player.displayName));
		}
	}

	@command("deop") deop1(ServerCommandSender sender, string player) {
		executeOnPlayers(sender, player, (shared PlayerInfo info){
			if(info.permissionLevel <= PermissionLevel.operator) {
				if(info.permissionLevel == PermissionLevel.operator) {
					sender.server.updatePlayerPermissionLevel(info, PermissionLevel.user);
					//TODO send message to the player
				}
				sender.sendMessage(Translation(Messages.deop.success, info.displayName));
			} else {
				sender.sendMessage(Format.red, Translation(Messages.deop.failed, info.displayName));
			}
		});
	}

	// difficulty
	
	@command("difficulty") @op difficulty0(WorldCommandSender sender, Difficulty difficulty) {
		sender.world.difficulty = difficulty;
		sender.sendMessage(Translation(Messages.difficulty.success, difficulty));
	}
	
	@command("difficulty") difficulty1(WorldCommandSender sender, Ranged!(ubyte, 0, 3) difficulty) {
		this.difficulty0(sender, cast(Difficulty)difficulty.value);
	}

	@command("difficulty") difficulty2(ServerCommandSender sender, string world, Difficulty difficulty) {
		executeOnWorlds(sender, world, (shared GroupInfo info){
			sender.server.updateGroupDifficulty(info, difficulty);
			sender.sendMessage(Translation(Messages.difficulty.success, difficulty));
		});

	}

	@command("difficulty") difficulty3(ServerCommandSender sender, string world, Ranged!(ubyte, 0, 3) difficulty) {
		this.difficulty2(sender, world, cast(Difficulty)difficulty.value);
	}

	// effect

	@unimplemented @command("effect") @op effect0(WorldCommandSender sender, SingleEnum!"clear" clear, Entity[] target) {}

	@unimplemented @command("effect") effect1(WorldCommandSender sender, SingleEnum!"clear" clear, Entity[] target, SnakeCaseEnum!Effects effect) {}

	alias Duration = Ranged!(uint, 0, 1_000_000);

	@unimplemented @command("effect") effect2(WorldCommandSender sender, SingleEnum!"give" give, Entity[] target, SnakeCaseEnum!Effects effect, Duration duration=Duration(30), ubyte amplifier=0, bool hideParticles=false) {}

	// enchant

	alias Level = Ranged!(ubyte, 1, ubyte.max);

	@unimplemented @command("enchant") @op enchant0(WorldCommandSender sender, Player[] target, SnakeCaseEnum!Enchantments enchantment, Level level=Level(1)) {}

	@command("enchant") enchant1(Player sender, SnakeCaseEnum!Enchantments enchantment, Level level=Level(1)) {
		this.enchant0(sender, [sender], enchantment, level);
	}

	// experience

	enum ExperienceAction { add, set }

	enum ExperienceType { points, levels }

	@unimplemented @command("experience") @op @aliases("xp") experience0(WorldCommandSender sender, ExperienceAction action, Player[] target, uint amount, ExperienceType type=ExperienceType.levels) {}

	@command("experience") experience1(Player sender, ExperienceAction action, uint amount, ExperienceType type=ExperienceType.levels) {
		this.experience0(sender, action, [sender], amount, type);
	}

	@unimplemented @command("experience") experience2(WorldCommandSender sender, SingleEnum!"query" query, Player target, ExperienceType type) {}

	@command("experience") experience3(Player sender, SingleEnum!"query" query, ExperienceType type) {
		this.experience2(sender, query, sender, type);
	}

	// execute

	//class ExecuteCommand : WorldCommandSender {}

	@unimplemented @command("execute") @op execute0(WorldCommandSender sender, Entity[] origin, Position position, string command) {}

	// fill

	enum OldBlockHandling { destroy, hollow, keep, outline, replace }

	@unimplemented @command("fill") @op fill0(WorldCommandSender sender, Position from, Position to, string block, OldBlockHandling oldBlockHandling=OldBlockHandling.replace) {}

	// gamemode

	@command("gamemode") @op @aliases("gm") gamemode0(WorldCommandSender sender, Gamemode gamemode, Player[] target) {
		foreach(player ; target) {
			player.gamemode = gamemode;
			sender.sendMessage(Translation(Messages.gamemode.successOther, player.displayName, gamemode));
		}
	}

	@command("gamemode") gamemode1(Player sender, Gamemode gamemode) {
		sender.gamemode = gamemode;
		sender.sendMessage(Translation(Messages.gamemode.successSelf, gamemode));
	}

	@command("gamemode") gamemode2(ServerCommandSender sender, Gamemode gamemode, string target) {
		executeOnPlayers(sender, target, (shared PlayerInfo info){
			sender.server.updatePlayerGamemode(info, gamemode);
			sender.sendMessage(Translation(Messages.gamemode.successOther, info.displayName, gamemode));
		});
	}

	// gamerule

	enum Gamerule { depleteHunger, doDaylightCycle, doWeatherCycle, naturalRegeneration, pvp, randomTickSpeed }

	@command("gamerule") @op gamerule0(WorldCommandSender sender) {
		sender.sendMessage(join([__traits(allMembers, Gamerule)], ", "));
	}

	@command("gamerule") gamerule1(WorldCommandSender sender, Gamerule rule) {
		//TODO
		sender.sendMessage(rule, " = ", {
			final switch(rule) with(Gamerule) {
				case depleteHunger: return sender.world.depleteHunger.to!string;
				case doDaylightCycle: return sender.world.time.cycle.to!string;
				case doWeatherCycle: return sender.world.weather.cycle.to!string;
				case naturalRegeneration: return sender.world.naturalRegeneration.to!string;
				case pvp: return sender.world.pvp.to!string;
				case randomTickSpeed: return sender.world.randomTickSpeed.to!string;
			}
		}());
	}

	@command("gamerule") gamerule2(WorldCommandSender sender, Gamerule rule, bool value) {
		//TODO
		switch(rule) with(Gamerule) {
			case depleteHunger: sender.world.depleteHunger = value; break;
			case doDaylightCycle: sender.world.time.cycle = value; break;
			case doWeatherCycle: sender.world.weather.cycle = value; break;
			case naturalRegeneration: sender.world.naturalRegeneration = value; break;
			case pvp: sender.world.pvp = value; break;
			default:
				sender.sendMessage(Format.red, Translation(Messages.gamerule.invalidType, rule));
				return;
		}
		sender.sendMessage(Translation(Messages.gamerule.success, rule, value));
	}

	@command("gamerule") gamerule3(WorldCommandSender sender, Gamerule rule, Ranged!(int, 0, int.max) value) {
		//TODO
		switch(rule) with(Gamerule) {
			case randomTickSpeed: sender.world.randomTickSpeed = value; break;
			default:
				sender.sendMessage(Format.red, Translation(Messages.gamerule.invalidType, rule));
				return;
		}
		sender.sendMessage(Translation(Messages.gamerule.success, rule, value.value));
	}
	
	// give
	
	@unimplemented @command("give") @op give0(WorldCommandSender sender, Player[] target, string item, ubyte amount=1) {}
	
	@command("give") give1(Player sender, string item, ubyte amount=1) {
		this.give0(sender, [sender], item, amount);
	}

	// help

	@command("help") @aliases("?") help0(JavaPlayer sender, int page=1) {
		// pocket players have the help command client-side
		Command[] commands;
		foreach(name, command; sender.availableCommands) {
			sender.server.logger.log(name);
			if(command.name == name && !command.hidden) commands ~= command;
		}
		sort!((a, b) => a.name < b.name)(commands);
		immutable pages = cast(size_t)ceil(commands.length.to!float / 7); // commands.length should always be at least 1 (help command)
		page = clamp(--page, 0, pages - 1);
		sender.sendMessage(Format.darkGreen, Translation(Messages.help.header, page+1, pages));
		foreach(command ; commands[page*7..min($, (page+1)*7)]) {
			if(command.description.type == Description.EMPTY) sender.sendMessage(command.name);
			else if(command.description.type == Description.TEXT) sender.sendMessage(command.name, " - ", command.description.text);
			else sender.sendMessage(command.name, " - ", Translation(command.description.translatable));
		}
		sender.sendMessage(Format.green, Translation(Messages.help.footer));
	}
	
	@command("help") help2(JavaPlayer sender, string command) {
		this.helpImpl(sender, "/", command);
	}
	
	private void helpImpl(CommandSender sender, string slash, string command) {
		auto cmd = command in sender.availableCommands;
		if(cmd) {
			string[] messages;
			foreach(overload ; cmd.overloads) {
				if(overload.callableBy(sender)) {
					messages ~= ("- " ~ slash ~ cmd.name ~ " " ~ formatArg(overload));
				}
			}
			if(messages.length) {
				if(cmd.aliases.length) {
					sender.sendMessage(Format.yellow, Translation(Messages.help.commandAliases, cmd.name, cmd.aliases.join(", ")));
				} else {
					sender.sendMessage(Format.yellow ~ cmd.name ~ ":");
				}
				if(cmd.description.type == Description.TEXT) {
					sender.sendMessage(Format.yellow, cmd.description.text);
				} else if(cmd.description.type == Description.TRANSLATABLE) {
					sender.sendMessage(Format.yellow, Translation(cmd.description.translatable));
				}
				sender.sendMessage(Translation(Messages.generic.usage, ""));
				foreach(message ; messages) {
					sender.sendMessage(message);
				}
				return;
			}
		}
		sender.sendMessage(Format.red, Translation(Messages.generic.invalidParameter, command));
	}

	// kick

	@command("kick") @op kick0(WorldCommandSender sender, Player[] target, string message) {
		string[] kicked;
		foreach(player ; target) {
			player.kick(message);
			kicked ~= player.displayName;
		}
		sender.sendMessage(Translation(Messages.kick.successReason, kicked.join(", "), message));
	}

	@command("kick") kick1(WorldCommandSender sender, Player[] target) {
		string[] kicked;
		foreach(player ; target) {
			player.kick();
			kicked ~= player.name;
		}
		sender.sendMessage(Translation(Messages.kick.success, kicked.join(", ")));
	}

	@command("kick") kick2(ServerCommandSender sender, string player, string message) {
		executeOnPlayers(sender, player, (shared PlayerInfo info){
			sender.server.kick(info.hubId, message);
			sender.sendMessage(Translation(Messages.kick.successReason, info.displayName, message));
		});
	}

	@command("kick") kick3(ServerCommandSender sender, string player) {
		executeOnPlayers(sender, player, (shared PlayerInfo info){
			server.kick(info.hubId, "disconnect.closed", []);
			sender.sendMessage(Translation(Messages.kick.success, info.displayName));
		});
	}

	// kill

	@unimplemented @command("kill") @op kill0(WorldCommandSender sender, Entity[] target) {}

	@command("kill") kill1(Player sender) {
		this.kill0(sender, [sender]);
	}

	// list

	@command("list") list0(CommandSender sender) {
		// list players on the current node
		sender.sendMessage(Translation(Messages.list.players, sender.server.online, sender.server.max));
		if(sender.server.online) {
			string[] names;
			foreach(player ; server.players) {
				names ~= player.displayName;
			}
			sender.sendMessage(names.join(", "));
		}
	}

	// locate

	enum StructureType { endcity, fortress, mansion, mineshaft, monument, stronghold, temple, village }

	@unimplemented @command("locate") @op locate0(WorldCommandSender sender, StructureType structureType) {}

	// me

	@command("me") me0(Player sender, string message) {
		//TODO replace target selectors with names
		sender.world.broadcast("* " ~ sender.displayName ~ Format.reset ~ " " ~ unformat(message));
	}

	// op

	@command("op") @op op0(WorldCommandSender sender, Player player) {
		if(!player.operator) {
			player.operator = true;
			player.sendMessage(Translation(Messages.op.message));
			sender.sendMessage(Translation(Messages.op.success, player.displayName));
		} else {
			sender.sendMessage(Format.red, Translation(Messages.op.failed, player.displayName));
		}
	}

	@command("op") op1(ServerCommandSender sender, string player) {
		executeOnPlayers(sender, player, (shared PlayerInfo info){
			if(info.permissionLevel < PermissionLevel.operator) {
				sender.server.updatePlayerPermissionLevel(info, PermissionLevel.operator);
				//TODO send message to the player
				sender.sendMessage(Translation(Messages.op.success, info.displayName));
			} else {
				sender.sendMessage(Format.red, Translation(Messages.op.failed, info.displayName));
			}
		});
	}

	// say

	@command("say") @op say0(WorldCommandSender sender, string message) {
		auto player = cast(Player)sender;
		immutable name = player is null ? "@" : player.displayName ~ Format.reset;
		//TODO convert targets into strings
		sender.world.broadcast("[" ~ name ~ "] " ~ message); //TODO unformat
	}

	@command("say") say1(ServerCommandSender sender, string message) {
		sender.server.broadcast("[@] " ~ message);
	}

	// seed

	@command("seed") @op seed0(WorldCommandSender sender) {
		sender.sendMessage(Translation(Messages.seed.success, sender.world.seed));
	}
	
	// setmaxplayers
	
	@command("setmaxplayers") @op setmaxplayers0(CommandSender sender, uint players) {
		sender.server.max = players;
		sender.sendMessage(Translation(Messages.setmaxplayers.success, players));
	}

	// setworldspawn

	@unimplemented @command("setworldspawn") @op setworldspawn0(WorldCommandSender sender, Position position) {}

	@command("setworldspawn") setworldspawn1(WorldCommandSender sender) {
		this.setworldspawn0(sender, Position(Position.Point(true, sender.position.x), Position.Point(true, sender.position.y), Position.Point(true, sender.position.z)));
	}

	// spawnpoint

	@unimplemented @command("spawnpoint") @op spawnpoint0(WorldCommandSender sender, Player[] target, Position position) {}

	@command("spawnpoint") spawnpoint1(WorldCommandSender sender, Player[] target) {
		this.spawnpoint0(sender, target, Position(Position.Point(true, sender.position.x), Position.Point(true, sender.position.y), Position.Point(true, sender.position.z)));
	}

	@command("spawnpoint") spawnpoint2(Player sender) {
		this.spawnpoint1(sender, [sender]);
	}

	// spreadplayers

	//TODO implement Rotation
	//@unimplemented @command("spreadplayers") @op spreadplayers0(WorldCommandSender sender, Rotation x, Rotation z, double spreadDistance, double maxRange, Entity[] target) {}

	// summon

	@unimplemented @command("summon") @op summon0(WorldCommandSender sender, string entityType, Position position) {}

	@unimplemented @command("summon") summon1(WorldCommandSender sender, string entityType) {}

	// tell

	@command("tell") @aliases("msg", "w") tell0(Player sender, Player[] recipient, string message) {
		string[] sent;
		foreach(player ; recipient) {
			if(player.id != sender.id) {
				player.sendMessage(Format.italic, Translation(Messages.message.incoming, sender.displayName, message));
				sent ~= player.displayName;
			}
		}
		if(sent.length) sender.sendMessage(Format.italic, Translation(Messages.message.outcoming, sent.join(", "), message));
		else sender.sendMessage(Format.red, Translation(Messages.message.sameTarget));
	}

	@command("tell") @op time0(WorldCommandSender sender, SingleEnum!"add" add, uint amount) {
		uint time = sender.world.time.time + amount;
		if(time >= 24000) sender.world.time.day += time / 24000;
		sender.world.time.time = time;
		sender.sendMessage(Translation(Messages.time.added, amount));
	}

	// time

	enum TimeQuery { day, daytime, gametime }

	@command("time") @op time1(WorldCommandSender sender, SingleEnum!"query" query, TimeQuery time) {
		final switch(time) with(TimeQuery) {
			case day:
				sender.sendMessage(Translation(Messages.time.queryDay, sender.world.time.day));
				break;
			case daytime:
				sender.sendMessage(Translation(Messages.time.queryDaytime, sender.world.time.time));
				break;
			case gametime:
				sender.sendMessage(Translation(Messages.time.queryGametime, sender.world.ticks));
				break;
		}
	}

	@command("time") @op time2(WorldCommandSender sender, SingleEnum!"set" set, uint amount) {
		sender.sendMessage(Translation(Messages.time.set, (sender.world.time.time = amount)));
	}

	@command("time") @op time3(WorldCommandSender sender, SingleEnum!"set" set, Time amount) {
		this.time2(sender, set, cast(uint)amount);
	}

	// title

	@command("title") @op title0(WorldCommandSender sender, Player[] target, SingleEnum!"clear" clear) {
		foreach(player ; target) player.clearTitle();
		//TODO send message
	}

	@command("title") title1(WorldCommandSender sender, Player[] target, SingleEnum!"reset" reset) {
		foreach(player ; target) player.resetTitle();
		//TODO send message
	}

	@unimplemented @command("title") title2(WorldCommandSender sender, Player[] target, SingleEnum!"title" title, string text) {}

	@unimplemented @command("title") title3(WorldCommandSender sender, Player[] target, SingleEnum!"subtitle" subtitle, string text) {}

	@unimplemented @command("title") title4(WorldCommandSender sender, Player[] target, SingleEnum!"actionbar" actionbar, string text) {
		foreach(player ; target) player.sendTip(text);
		//TODO send message
	}

	@unimplemented @command("title") title5(WorldCommandSender sender, Player[] target, SingleEnum!"times" times, uint fadeIn, uint stay, uint fadeOut) {}

	// toggledownfall

	@command("toggledownfall") @op toggledownfall0(WorldCommandSender sender) {
		if(sender.world.weather.raining) sender.world.weather.clear();
		else sender.world.weather.start();
		sender.sendMessage(Translation(Messages.toggledownfall.success));
	}

	// tp

	@command("tp") @op @permission("minecraft:teleport") @aliases("teleport") tp0(Player sender, Entity destination) {
		this.tp2(sender, [sender], destination);
	}

	@command("tp") tp1(Player sender, Position destination) {
		this.tp3(sender, [sender], destination);
	}

	@unimplemented @command("tp") tp2(WorldCommandSender sender, Entity[] victim, Entity destination) {}

	@unimplemented @command("tp") tp3(WorldCommandSender sender, Entity[] victim, Position destination) {}

	// transferserver
	
	@command("transferserver") @op transferserver0(Player sender, string ip, int port=19132) {
		immutable _port = cast(ushort)port;
		if(_port == port) {
			try {
				sender.transfer(ip, _port);
			} catch(Exception) {}
		} else {
			sender.sendMessage(Format.red, Translation(Messages.transferserver.invalidPort));
		}
	}

	@command("transferserver") transferserver1(WorldCommandSender sender, Player[] target, string ip, int port=19132) {
		immutable _port = cast(ushort)port;
		if(_port == port) {
			bool success = false;
			foreach(player ; target) {
				try {
					player.transfer(ip, _port);
					success = true;
				} catch(Exception) {}
			}
			if(success) sender.sendMessage(Translation(Messages.transferserver.success));
		} else {
			sender.sendMessage(Format.red, Translation(Messages.transferserver.invalidPort));
		}
	}

	// weather

	enum Weather { clear, rain, thunder }

	@command("weather") @op weather0(WorldCommandSender sender, Weather type, int duration=0) {
		if(type == Weather.clear) {
			if(duration <= 0) sender.world.weather.clear();
			else sender.world.weather.clear(duration);
			sender.sendMessage(Translation(Messages.weather.clear));
		} else {
			if(duration <= 0 || duration > 1_000_000) duration = uniform!"[]"(6000, 18000, sender.world.random);
			if(type == Weather.rain) {
				sender.world.weather.start(duration, false);
				sender.sendMessage(Translation(Messages.weather.rain));
			} else {
				sender.world.weather.start(duration, true);
				sender.sendMessage(Translation(Messages.weather.thunder));
			}
		}
	}

}

string convertName(string command, string replacement=" ") {
	string ret;
	foreach(c ; command) {
		if(c >= 'A' && c <= 'Z') ret ~= replacement ~ cast(char)(c + 32);
		else ret ~= c;
	}
	return ret;
}

private enum convertedName(string command) = convertName(command);

private string[] formatArgs(Command command, CommandSender sender) {
	string[] ret;
	foreach(overload ; command.overloads) {
		if(overload.callableBy(sender)) ret ~= formatArg(overload);
	}
	return ret;
}

private string formatArg(Command.Overload overload) {
	string[] p;
	foreach(i, param; overload.params) {
		immutable enum_ = overload.pocketTypeOf(i) == PocketType.stringenum;
		if(enum_ && overload.enumMembers(i).length == 1) {
			p ~= overload.enumMembers(i)[0];
		} else {
			string full = enum_ && overload.enumMembers(i).length < 5 ? overload.enumMembers(i).join("|") : (param ~ ": " ~ overload.typeOf(i));
			if(i < overload.requiredArgs) {
				p ~= "<" ~ full ~ ">";
			} else {
				p ~= "[" ~ full ~ "]";
			}
		}
	}
	return p.join(" ");
}

private void executeOnWorlds(CommandSender sender, string name, void delegate(shared GroupInfo) del) {
	auto group = sender.server.getGroupByName(name);
	if(group !is null) {
		del(group);
	} else {
		sender.sendMessage(Format.red, Translation("commands.world.notFound", name));
	}
}

private void executeOnPlayers(CommandSender sender, string name, void delegate(shared PlayerInfo) del) {
	if(name.startsWith("@")) {
		if(name == "@a" || name == "@r") {
			auto players = sender.server.players;
			if(players.length) {
				final switch(name) {
					case "@a":
						foreach(player ; sender.server.players) {
							del(player);
						}
						break;
					case "@r":
						del(players[uniform(0, $)]);
						break;
				}
			} else {
				sender.sendMessage(Format.red, Translation(Messages.generic.targetNotFound));
			}
		} else {
			sender.sendMessage(Format.red, Translation(Messages.generic.invalidSyntax));
		}
	} else {
		immutable iname = name.toLower();
		bool executed = false;
		foreach(player ; sender.server.players) {
			if(player.lname == iname) {
				executed = true;
				del(player);
			}
		}
		if(!executed) sender.sendMessage(Format.red, Translation(Messages.generic.playerNotFound, name));
	}
}

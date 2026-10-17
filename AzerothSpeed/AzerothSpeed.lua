-- AzerothSpeed: WoW 1.12 style (Lua 5.0). Probes the client for a timescale hook.
-- /azspeed probe        try ConsoleExec "cvarlist <word>" for speed/time words
-- /azspeed <number>     try every known candidate name with that value
-- /azspeed get <name>   print a CVar
-- /azspeed set <n> <v>  set a CVar directly

local CANDIDATES = {
  "timescale", "timeScale", "gameSpeed", "gamespeed", "simSpeed", "simspeed",
  "runSpeed", "relativeSpeed", "gameTimeScale", "speed", "timeSpeed",
};
local WORDS = { "speed", "time", "scale", "pace", "fast", "sim" };

local function say(msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99AzerothSpeed:|r "..tostring(msg));
end

local function try(name, value)
  local before = GetCVar(name);
  if before == nil then return false; end
  SetCVar(name, value);
  say(name..": "..tostring(before).." -> "..tostring(GetCVar(name)));
  return true;
end

local function handler(msg)
  msg = msg or "";
  if msg == "" or msg == "help" then
    say("/azspeed probe | /azspeed <number> | /azspeed get <name> | /azspeed set <name> <value>");
    return;
  end
  if msg == "probe" then
    say("Listing CVars matching speed/time words (results go to chat or console)...");
    for i = 1, getn(WORDS) do
      ConsoleExec("cvarlist "..WORDS[i]);
    end
    for i = 1, getn(CANDIDATES) do
      local v = GetCVar(CANDIDATES[i]);
      if v ~= nil then say("FOUND "..CANDIDATES[i].." = "..tostring(v)); end
    end
    return;
  end
  local _, _, name = string.find(msg, "^get%s+(%S+)");
  if name then say(name.." = "..tostring(GetCVar(name))); return; end
  local _, _, n2, v2 = string.find(msg, "^set%s+(%S+)%s+(%S+)");
  if n2 then SetCVar(n2, v2); say(n2.." = "..tostring(GetCVar(n2))); return; end
  local num = tonumber(msg);
  if num then
    local hit = false;
    for i = 1, getn(CANDIDATES) do
      if try(CANDIDATES[i], num) then hit = true; end
    end
    if not hit then
      say("No candidate CVar exists. Not exposed to addons in this build (found none in the client strings).");
    end
    return;
  end
  say("Unknown argument. /azspeed help");
end

SLASH_AZSPEED1 = "/azspeed";
SlashCmdList["AZSPEED"] = handler;

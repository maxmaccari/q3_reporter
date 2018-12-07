defmodule ParserTest do
  use ExUnit.Case

  alias Q3Reporter.Parser

  @game1 """
    0:00 ------------------------------------------------------------
    0:00 InitGame: \\sv_floodProtect\\1\\sv_maxPing\\0\\sv_minPing\\0\\sv_maxRate\\10000\\sv_minRate\\0\\sv_hostname\\Code Miner Server\\g_gametype\\0\\sv_privateClients\\2\\sv_maxclients\\16\\sv_allowDownload\\0\\dmflags\\0\\fraglimit\\20\\timelimit\\15\\g_maxGameClients\\0\\capturelimit\\8\\version\\ioq3 1.36 linux-x86_64 Apr 12 2009\\protocol\\68\\mapname\\q3dm17\\gamename\\baseq3\\g_needpass\\0
   15:00 Exit: Timelimit hit.
   20:34 ClientConnect: 2
   20:34 ClientUserinfoChanged: 2 n\\Isgalamido\\t\\0\\model\\xian/default\\hmodel\\xian/default\\g_redteam\\\\g_blueteam\\\\c1\\4\\c2\\5\\hc\\100\\w\\0\\l\\0\\tt\\0\\tl\\0
   20:37 ClientUserinfoChanged: 2 n\\Isgalamido\\t\\0\\model\\uriel/zael\\hmodel\\uriel/zael\\g_redteam\\\\g_blueteam\\\\c1\\5\\c2\\5\\hc\\100\\w\\0\\l\\0\\tt\\0\\tl\\0
   20:37 ClientBegin: 2
   20:37 ShutdownGame:
   20:37 ------------------------------------------------------------
  """

  test "parse game1" do
    assert Parser.parse(@game1) == [%{
      players: [
        %{
          id: "2",
          nickname: "Isgalamido",
          kills: 0,
          deaths: 0
        }
      ],
      total_kills: 0
    }]
  end

  test "parse multiple games" do
    games =
      @game1
      |> String.duplicate(10)
      |> Parser.parse()

    assert length(games) == 10
  end

  @game2 """
   20:37 ------------------------------------------------------------
   20:37 InitGame: \\sv_floodProtect\\1\\sv_maxPing\\0\\sv_minPing\\0\\sv_maxRate\\10000\\sv_minRate\\0\\sv_hostname\\Code Miner Server\\g_gametype\\0\\sv_privateClients\\2\\sv_maxclients\\16\\sv_allowDownload\\0\\bot_minplayers\\0\\dmflags\\0\\fraglimit\\20\\timelimit\\15\\g_maxGameClients\\0\\capturelimit\\8\\version\\ioq3 1.36 linux-x86_64 Apr 12 2009\\protocol\\68\\mapname\\q3dm17\\gamename\\baseq3\\g_needpass\\0
   20:38 ClientConnect: 2
   20:38 ClientUserinfoChanged: 2 n\\Isgalamido\\t\\0\\model\\uriel/zael\\hmodel\\uriel/zael\\g_redteam\\\\g_blueteam\\\\c1\\5\\c2\\5\\hc\\100\\w\\0\\l\\0\\tt\\0\\tl\\0
   20:38 ClientBegin: 2
   20:40 Item: 2 weapon_rocketlauncher
   20:40 Item: 2 ammo_rockets
   20:42 Item: 2 item_armor_body
   20:54 Kill: 1022 2 22: <world> killed Isgalamido by MOD_TRIGGER_HURT
   20:59 Item: 2 weapon_rocketlauncher
   21:04 Item: 2 ammo_shells
   21:07 Kill: 1022 2 22: <world> killed Isgalamido by MOD_TRIGGER_HURT
   21:10 ClientDisconnect: 2
   21:15 ClientConnect: 2
   21:15 ClientUserinfoChanged: 2 n\\Isgalamido\\t\\0\\model\\uriel/zael\\hmodel\\uriel/zael\\g_redteam\\\\g_blueteam\\\\c1\\5\\c2\\5\\hc\\100\\w\\0\\l\\0\\tt\\0\\tl\\0
   21:17 ClientUserinfoChanged: 2 n\\Isgalamido\\t\\0\\model\\uriel/zael\\hmodel\\uriel/zael\\g_redteam\\\\g_blueteam\\\\c1\\5\\c2\\5\\hc\\100\\w\\0\\l\\0\\tt\\0\\tl\\0
   21:17 ClientBegin: 2
   21:18 Item: 2 weapon_rocketlauncher
   21:21 Item: 2 item_armor_body
   21:32 Item: 2 item_health_large
   21:33 Item: 2 weapon_rocketlauncher
   21:34 Item: 2 ammo_rockets
   21:42 Kill: 1022 2 22: <world> killed Isgalamido by MOD_TRIGGER_HURT
   21:49 Item: 2 weapon_rocketlauncher
   21:51 ClientConnect: 3
   21:51 ClientUserinfoChanged: 3 n\\Dono da Bola\\t\\0\\model\\sarge/krusade\\hmodel\\sarge/krusade\\g_redteam\\\\g_blueteam\\\\c1\\5\\c2\\5\\hc\\95\\w\\0\\l\\0\\tt\\0\\tl\\0
   21:53 ClientUserinfoChanged: 3 n\\Mocinha\\t\\0\\model\\sarge\\hmodel\\sarge\\g_redteam\\\\g_blueteam\\\\c1\\4\\c2\\5\\hc\\95\\w\\0\\l\\0\\tt\\0\\tl\\0
   21:53 ClientBegin: 3
   22:04 Item: 2 weapon_rocketlauncher
   22:04 Item: 2 ammo_rockets
   22:06 Kill: 2 3 7: Isgalamido killed Mocinha by MOD_ROCKET_SPLASH
   22:11 Item: 2 item_quad
   22:11 ClientDisconnect: 3
   22:18 Kill: 2 2 7: Isgalamido killed Isgalamido by MOD_ROCKET_SPLASH
   22:26 Item: 2 weapon_rocketlauncher
   22:27 Item: 2 ammo_rockets
   22:40 Kill: 2 2 7: Isgalamido killed Isgalamido by MOD_ROCKET_SPLASH
   22:43 Item: 2 weapon_rocketlauncher
   22:45 Item: 2 item_armor_body
   23:06 Kill: 1022 2 22: <world> killed Isgalamido by MOD_TRIGGER_HURT
   23:09 Item: 2 weapon_rocketlauncher
   23:10 Item: 2 ammo_rockets
   23:25 Item: 2 item_health_large
   23:30 Item: 2 item_health_large
   23:32 Item: 2 weapon_rocketlauncher
   23:35 Item: 2 item_armor_body
   23:36 Item: 2 ammo_rockets
   23:37 Item: 2 weapon_rocketlauncher
   23:40 Item: 2 item_armor_shard
   23:40 Item: 2 item_armor_shard
   23:40 Item: 2 item_armor_shard
   23:40 Item: 2 item_armor_combat
   23:43 Item: 2 weapon_rocketlauncher
   23:57 Item: 2 weapon_shotgun
   23:58 Item: 2 ammo_shells
   24:13 Item: 2 item_armor_shard
   24:13 Item: 2 item_armor_shard
   24:13 Item: 2 item_armor_shard
   24:13 Item: 2 item_armor_combat
   24:16 Item: 2 item_health_large
   24:18 Item: 2 ammo_rockets
   24:19 Item: 2 weapon_rocketlauncher
   24:22 Item: 2 item_armor_body
   24:24 Item: 2 ammo_rockets
   24:24 Item: 2 weapon_rocketlauncher
   24:36 Item: 2 item_health_large
   24:43 Item: 2 item_health_mega
   25:05 Kill: 1022 2 22: <world> killed Isgalamido by MOD_TRIGGER_HURT
   25:09 Item: 2 weapon_rocketlauncher
   25:09 Item: 2 ammo_rockets
   25:11 Item: 2 item_armor_body
   25:18 Kill: 1022 2 22: <world> killed Isgalamido by MOD_TRIGGER_HURT
   25:21 Item: 2 weapon_rocketlauncher
   25:22 Item: 2 ammo_rockets
   25:34 Item: 2 weapon_rocketlauncher
   25:41 Kill: 1022 2 19: <world> killed Isgalamido by MOD_FALLING
   25:50 Item: 2 item_armor_combat
   25:52 Kill: 1022 2 22: <world> killed Isgalamido by MOD_TRIGGER_HURT
   25:54 Item: 2 ammo_rockets
   25:55 Item: 2 weapon_rocketlauncher
   25:55 Item: 2 weapon_rocketlauncher
   25:59 Item: 2 item_armor_shard
   25:59 Item: 2 item_armor_shard
   26:05 Item: 2 item_armor_shard
   26:05 Item: 2 item_armor_shard
   26:05 Item: 2 item_armor_shard
   26:09 Item: 2 weapon_rocketlauncher
  """

  test "parse game with multiple players" do
    assert Parser.parse(@game2) == [%{
      players: [
        %{
          id: "3",
          nickname: "Mocinha",
          kills: 0,
          deaths: 1
        },
        %{
          id: "2",
          nickname: "Isgalamido",
          kills: -5,
          deaths: 10
        }
      ],
      total_kills: 11
    }]
  end

  @game3 """
    0:00 ------------------------------------------------------------
    0:00 InitGame: \\sv_floodProtect\\1\\sv_maxPing\\0\\sv_minPing\\0\\sv_maxRate\\10000\\sv_minRate\\0\\sv_hostname\\Code Miner Server\\g_gametype\\0\\sv_privateClients\\2\\sv_maxclients\\16\\sv_allowDownload\\0\\dmflags\\0\\fraglimit\\20\\timelimit\\15\\g_maxGameClients\\0\\capturelimit\\8\\version\\ioq3 1.36 linux-x86_64 Apr 12 2009\\protocol\\68\\mapname\\q3dm17\\gamename\\baseq3\\g_needpass\\0
    0:25 ClientConnect: 2
    0:25 ClientUserinfoChanged: 2 n\\Dono da Bola\\t\\0\\model\\sarge/krusade\\hmodel\\sarge/krusade\\g_redteam\\\\g_blueteam\\\\c1\\5\\c2\\5\\hc\\95\\w\\0\\l\\0\\tt\\0\\tl\\0
    0:27 ClientUserinfoChanged: 2 n\\Mocinha\\t\\0\\model\\sarge\\hmodel\\sarge\\g_redteam\\\\g_blueteam\\\\c1\\4\\c2\\5\\hc\\95\\w\\0\\l\\0\\tt\\0\\tl\\0
    0:27 ClientBegin: 2
    0:29 Item: 2 weapon_rocketlauncher
    0:35 Item: 2 item_armor_shard
    0:35 Item: 2 item_armor_shard
    0:35 Item: 2 item_armor_shard
    0:35 Item: 2 item_armor_combat
    0:38 Item: 2 item_armor_shard
    0:38 Item: 2 item_armor_shard
    0:38 Item: 2 item_armor_shard
    0:55 Item: 2 item_health_large
    0:56 Item: 2 weapon_rocketlauncher
    0:57 Item: 2 ammo_rockets
    0:59 ClientConnect: 3
    0:59 ClientUserinfoChanged: 3 n\\Isgalamido\\t\\0\\model\\xian/default\\hmodel\\xian/default\\g_redteam\\\\g_blueteam\\\\c1\\4\\c2\\5\\hc\\100\\w\\0\\l\\0\\tt\\0\\tl\\0
    1:01 ClientUserinfoChanged: 3 n\\Isgalamido\\t\\0\\model\\uriel/zael\\hmodel\\uriel/zael\\g_redteam\\\\g_blueteam\\\\c1\\5\\c2\\5\\hc\\100\\w\\0\\l\\0\\tt\\0\\tl\\0
    1:01 ClientBegin: 3
    1:02 Item: 3 weapon_rocketlauncher
    1:04 Item: 2 item_armor_shard
    1:04 Item: 2 item_armor_shard
    1:04 Item: 2 item_armor_shard
    1:06 ClientConnect: 4
    1:06 ClientUserinfoChanged: 4 n\\Zeh\\t\\0\\model\\sarge/default\\hmodel\\sarge/default\\g_redteam\\\\g_blueteam\\\\c1\\5\\c2\\5\\hc\\100\\w\\0\\l\\0\\tt\\0\\tl\\0
    1:08 Kill: 3 2 6: Isgalamido killed Mocinha by MOD_ROCKET
    1:08 ClientUserinfoChanged: 4 n\\Zeh\\t\\0\\model\\sarge/default\\hmodel\\sarge/default\\g_redteam\\\\g_blueteam\\\\c1\\1\\c2\\5\\hc\\100\\w\\0\\l\\0\\tt\\0\\tl\\0
    1:08 ClientBegin: 4
    1:10 Item: 3 item_armor_shard
    1:10 Item: 3 item_armor_shard
    1:10 Item: 3 item_armor_shard
    1:10 Item: 3 item_armor_combat
    1:11 Item: 4 weapon_shotgun
    1:11 Item: 4 ammo_shells
    1:16 Item: 4 item_health_large
    1:18 Item: 4 weapon_rocketlauncher
    1:18 Item: 4 ammo_rockets
    1:26 Kill: 1022 4 22: <world> killed Zeh by MOD_TRIGGER_HURT
    1:26 ClientUserinfoChanged: 2 n\\Dono da Bola\\t\\0\\model\\sarge\\hmodel\\sarge\\g_redteam\\\\g_blueteam\\\\c1\\4\\c2\\5\\hc\\95\\w\\0\\l\\0\\tt\\0\\tl\\0
    1:26 Item: 3 weapon_railgun
    1:29 Item: 2 weapon_rocketlauncher
    1:29 Item: 3 weapon_railgun
    1:32 Item: 3 weapon_railgun
    1:32 Kill: 1022 4 22: <world> killed Zeh by MOD_TRIGGER_HURT
    1:35 Item: 2 item_armor_shard
    1:35 Item: 2 item_armor_shard
    1:35 Item: 2 item_armor_shard
    1:35 Item: 3 weapon_railgun
    1:38 Item: 2 item_health_large
    1:38 Item: 3 weapon_railgun
    1:41 Kill: 1022 2 19: <world> killed Dono da Bola by MOD_FALLING
    1:41 Item: 3 weapon_railgun
    1:43 Item: 2 ammo_rockets
    1:44 Item: 2 weapon_rocketlauncher
    1:46 Item: 2 item_armor_shard
    1:47 Item: 2 item_armor_shard
    1:47 Item: 2 item_armor_shard
    1:47 ShutdownGame:
    1:47 ------------------------------------------------------------
  """

  test "parse multiple games with multiples kills" do
    games = "#{@game1}#{@game2}#{@game3}"

    assert Parser.parse(games) == [
      %{
        players: [
          %{deaths: 2, id: "4", kills: -2, nickname: "Zeh"},
          %{deaths: 0, id: "3", kills: 1, nickname: "Isgalamido"},
          %{deaths: 2, id: "2", kills: -1, nickname: "Dono da Bola"}
        ],
        total_kills: 4
      },
      %{
        players: [
          %{deaths: 1, id: "3", kills: 0, nickname: "Mocinha"},
          %{deaths: 10, id: "2", kills: -5, nickname: "Isgalamido"}
        ],
        total_kills: 11
      },
      %{
        players: [%{deaths: 0, id: "2", kills: 0, nickname: "Isgalamido"}],
        total_kills: 0
      }
    ]
  end
end

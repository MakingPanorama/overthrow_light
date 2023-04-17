/*
    Author: DDSuper
    Description: Custom topbar is optimized for overthrow so it's easy to
    to control information
*/
teams = [];

function DeleteAllTeamPanels()
{
    let TeamsContainer = $("#overthrow_light_teams_container")
    let IChildren = TeamsContainer.GetChildCount();
    if ( IChildren > 0 )
    {
        for ( let i = 0; i < IChildren; i++ )
        {
            TeamsContainer.GetChild( i ).DeleteAsync( 0 );
        }
    }
}

function UpdatePlayerPanel(player_container, playerId, localPlayerTeamId)
{
    let playerPanelName = "player_" + playerId;
    let playerPanel = player_container.FindChild(playerPanelName)
    if ( playerPanel === null )
    {
        playerPanel = $.CreatePanel("Panel", player_container, playerPanelName)
        playerPanel.BLoadLayoutSnippet("player_panel");
        playerPanel.SetAttributeInt("player_id", playerId);
    }
    playerPanel.SetHasClass("is_local_player", playerId == Game.GetLocalPlayerID())
    
    let ultStateOrTime = PlayerUltimateStateOrTime_t.PLAYER_ULTIMATE_STATE_HIDDEN;
    let respawn_time_container = playerPanel.FindChild("overthrow_light_respawn_container");
    let respawn_time_label = respawn_time_container.FindChild("overthrow_light_respawn_indicator");
    let isTeammate = false;

    let playerInfo = Game.GetPlayerInfo( playerId );
    if ( playerInfo )
    {
        isTeammate = ( playerInfo.player_team_id == localPlayerTeamId )
        if ( isTeammate )
        {
            ultStateOrTime = Game.GetPlayerUltimateStateOrTime( playerId );
        }

        playerPanel.SetHasClass( "player_dead", (playerInfo.player_respawn_seconds + 1 > 0) )
        //playerPanel.SetHasClass( "local_player_teammate", isTeammate && ( playerId != Game.GetLocalPlayerID() ) );
        if ( playerInfo.player_respawn_seconds + 1 > 0 )
        {
            respawn_time_container.style.opacity = 1;
        } else {
            respawn_time_container.style.opacity = 0; 
        }

        respawn_time_label.text = playerInfo.player_respawn_seconds;
        let playerPortrait = playerPanel.FindChild("overthrow_light_portait").FindChild("overthrow_light_hero");
        if ( playerPortrait )
        {
            if ( playerInfo.player_selected_hero !== "" )
            {
                playerPortrait.heroname = playerInfo.player_selected_hero;
            } 
            else 
            {
                $.Msg('unassigned');
            }
        }
    }
}
function UpdateTeamPanel(teamDetails, teamsInfo)
{
    let teamId = teamDetails.team_id; 
    let teamPanelName = "team_"+teamId;
    let teamPanel = $("#overthrow_light_teams_container").FindChild( teamPanelName );
    if ( teamPanel === null )
    {
        teamPanel = $.CreatePanel("Panel", $("#overthrow_light_teams_container"), teamPanelName);
        teamPanel.SetAttributeInt( "team_id", teamId);
        teamPanel.BLoadLayoutSnippet("team_panel");
        teamPanel.style["border-top"] = `1px solid ${GameUI.CustomUIConfig().team_colors[teamId]}`
    }
    
    let localPlayerTeamID = -1;
    let localPlayer = Game.GetLocalPlayerInfo();
    if ( localPlayer )
    {
        localPlayerTeamID = localPlayer;
    }
    
    //teamPanel.SetHasClass("local_player_team", localPlayerTeamID == teamId);
    //teamPanel.SetHasClass( "not_local_player_team", localPlayerTeamId != teamId );
    // Add players to team panel
    let teamPlayers = Game.GetPlayerIDsOnTeam( teamId );
    let main_container = teamPanel.FindChild("overthrow_light_team_container");
    let kills_label = main_container.FindChild("overthrow_light_kills_label");
    let player_container = main_container.FindChild("overthrow_light_team_player_container")
    if ( player_container )
    {
        for ( let playerID of teamPlayers )
        {
            UpdatePlayerPanel(player_container, playerID, localPlayerTeamID);
        }

        kills_label.text = Game.GetTeamDetails(teamId).team_score;
    }

    return teamPanel
}

function stableCompareFunc( a, b )
{
	var unstableCompare = compareFunc( a, b );
	if ( unstableCompare != 0 )
	{
		return unstableCompare;
	}
	
	if ( GameUI.CustomUIConfig().teamsPrevPlace.length <= a.team_id )
	{
		return 0;
	}
	
	if ( GameUI.CustomUIConfig().teamsPrevPlace.length <= b.team_id )
	{
		return 0;
	}
	
//			$.Msg( GameUI.CustomUIConfig().teamsPrevPlace );

	var a_prev = GameUI.CustomUIConfig().teamsPrevPlace[ a.team_id ];
	var b_prev = GameUI.CustomUIConfig().teamsPrevPlace[ b.team_id ];
	if ( a_prev < b_prev ) // [ A, B ]
	{
		return -1; // [ A, B ]
	}
	else if ( a_prev > b_prev ) // [ B, A ]
	{
		return 1; // [ B, A ]
	}
	else
	{
		return 0;
	}
};

// sort / reorder as necessary
function compareFunc( a, b ) // GameUI.CustomUIConfig().sort_teams_compare_func;
{
	if ( a.team_score < b.team_score )
	{
		return 1; // [ B, A ]
	}
	else if ( a.team_score > b.team_score )
	{
		return -1; // [ A, B ]
	}
	else
	{
		return 0;
	}
};

// Reorder teams
function ReorderTeam( teamsParent, teamPanel, teamId, newPlace, prevPanel)
{
    let oldPlace = null;
    if ( GameUI.CustomUIConfig().teamInfo.length > teamId )
	{
		oldPlace = GameUI.CustomUIConfig().teamsPrevPlace[ teamId ];
	}
    GameUI.CustomUIConfig().teamsPrevPlace[ teamId ] = newPlace;
    if ( newPlace != oldPlace )
    {
        // Code here
    }

    teamsParent.MoveChildAfter( teamPanel, prevPanel );
}

// Util function updates teams and player panels
function UpdateAllTeamsAndPlayer( teamsContainer )
{
    let teamList = [];
    for ( let teamID of Game.GetAllTeamIDs() )
    {
        if (Game.GetPlayerIDsOnTeam(teamID).length > 0) {
            teamList.push( Game.GetTeamDetails( teamID ) );     
        }
    }

    /*teamsList.sort((a,b) => {
        return a.value - b.value;
    }) */

    // Looping 
    let teamsInfo = { max_team_players: 0 };
    let panelsByTeam = [];
    for ( let i = 0; i < teamList.length; i++ )
    {   
        if (Game.GetPlayerIDsOnTeam(teamList[i].team_id).length > 0) {
            let teamPanel = UpdateTeamPanel(teamList[i], teamsInfo);
            if ( teamPanel )
            {
                panelsByTeam[ teamList[i].team_id ] = teamPanel;
            }
        }
    }
    
    if ( teamList.length > 1 )
    {
        teamList.sort( stableCompareFunc );
        
        let prevPanel = panelsByTeam[teamList[0].team_id]
        for ( let i=0; i < teamList.length; i++ )
        {
            let teamsContainer = $("#overthrow_light_teams_container");
            let teamId = teamList[i].team_id;
            let teamPanel = panelsByTeam[teamId];
            ReorderTeam(teamsContainer, teamPanel, teamId, i, prevPanel)
            prevPanel = teamPanel;
        }
    }
}

// Intialize scoreboard
function InitalizeScoreboard()
{
    GameUI.CustomUIConfig().teamsPrevPlace = [];
    $.Msg(GameUI.CustomUIConfig().teamsPrevPlace)
    UpdateAllTeamsAndPlayer($("#overthrow_light_teams_container"));
}

// Update all teams and player
function UpdateScoreboard()
{
    UpdateAllTeamsAndPlayer($("#overthrow_light_teams_container"));
}

// Loop the process
function loopUpdate()
{
    $.Schedule(0.2, () => {
        UpdateScoreboard();
        loopUpdate();
    })
}

// Initalize scoreboard
(function(){
    InitalizeScoreboard();
    loopUpdate();
})();

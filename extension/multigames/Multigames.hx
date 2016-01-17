package extension.multigames;

#if (android && !amazon)
	import extension.gpg.GooglePlayGames;
#elseif amazon
	import extension.gc.GameCircle;
#elseif ios
	import extension.gamecenter.GameCenter;
	import extension.gamecenter.GameCenterEvent;
#end

class Multigames {

	public static inline var ACHIEVEMENT_STATUS_LOCKED:Int = 0;
	public static inline var ACHIEVEMENT_STATUS_UNLOCKED:Int = 1;

	//////////////////////////////////////////////////////////////////////
	///////////// INIT's
	//////////////////////////////////////////////////////////////////////

	public static function initGoogleSocialFeatures(enableCloudStorage:Bool) {
		#if (android && !amazon)
			GooglePlayGames.init(enableCloudStorage);
		#end
	}

	public static function initAmazonSocialFeatures(enableWhispersync:Bool) {
		#if amazon
			GameCircle.init(enableWhispersync);
		#end
	}

	public static function initAppleSocialFeatures() {
		#if ios
			GameCenter.authenticate();
		#end
	}

	//////////////////////////////////////////////////////////////////////
	///////////// ACHIEVEMENTS
	//////////////////////////////////////////////////////////////////////

	public static function displayAchievements():Bool {
		#if (android && !amazon)
			return (GooglePlayGames.displayAchievements());
		#elseif amazon
			return (GameCircle.displayAchievements());
		#elseif ios
			GameCenter.showAchievements();
			return true;
		#else
			return false;
		#end
	}

	public static function unlock(idAchievement:String):Bool {
		#if (android && !amazon)
			return (GooglePlayGames.unlock(idAchievement));
		#elseif amazon
			return (GameCircle.unlock(idAchievement));
		#elseif ios
			GameCenter.reportAchievement(idAchievement, 100);
			return true;
		#else
			return false;
		#end
	}

		private static var totalStepsHash:Map<String, Int> = new Map<String, Int>();
		private static var currentStepsHash:Map<String, Int> = new Map<String, Int>();

		public static function setAchievementTotalSteps(idAchievement:String, totalSteps:Int):Void {
			totalStepsHash.set(idAchievement, totalSteps);
			currentStepsHash.set(idAchievement, 0);
		}

	public static function setSteps(idAchievement:String, steps:Int):Bool {
		#if (android && !amazon)
			return (GooglePlayGames.setSteps(idAchievement, steps));
		#elseif amazon
			if (currentStepsHash.get(idAchievement) < steps) currentStepsHash.set(idAchievement, steps);
			return (GameCircle.setSteps(idAchievement, (100.0 * steps) / totalStepsHash.get(idAchievement)));
		#elseif ios
			if (currentStepsHash.get(idAchievement) < steps) currentStepsHash.set(idAchievement, steps);
			GameCenter.reportAchievement(idAchievement, (100.0 * steps) / totalStepsHash.get(idAchievement));
			return true;
		#else
			return false;
		#end
	}

	public static function increment(idAchievement:String, steps:Int):Bool {
		#if (android && !amazon)
			return (GooglePlayGames.increment(idAchievement, steps));
		#elseif amazon
			var newCantSteps = steps + currentStepsHash.get(idAchievement);
			setSteps(idAchievement, newCantSteps);
			// function internalIncrement(internalIdAchievement:String, internalSteps:Int) {
				// var newCantSteps = steps + internalSteps;
				// trace(" ---- "+ newCantSteps);
				// setSteps(internalIdAchievement, newCantSteps);
			// }

			// setOnGetPlayerCurrentSteps(internalIncrement);
			// getCurrentAchievementSteps(idAchievement);

			return true;
		#elseif ios
			var newCantSteps = steps + currentStepsHash.get(idAchievement);
			setSteps(idAchievement, newCantSteps);
			return true;
		#else
			return false;
		#end
	}

	public static function reveal(idAchievement:String):Bool {
		#if (android && !amazon)
			return (GooglePlayGames.reveal(idAchievement));
		#elseif amazon
			trace("Not implemented in GameCircle.");
			return true;
		#elseif ios
			GameCenter.reportAchievement(idAchievement, 0);
			return true;
		#else
			return false;
		#end
	}

	public static function getAchievementStatus(idAchievement:String):Bool {
		#if (android && !amazon)
			return (GooglePlayGames.getAchievementStatus(idAchievement));
		#elseif amazon
			return (GameCircle.getAchievementStatus(idAchievement));
		#elseif ios
			GameCenter.getAchievementStatus(idAchievement);
			return true;
		#else
			return false;
		#end
	}

		// ------------ Callback getAchievementStatus ------------
		public static function setOnGetPlayerAchievementStatus(onGetPlayerAchievementStatus:String->Int->Void) {
			#if (android && !amazon)
				GooglePlayGames.onGetPlayerAchievementStatus = onGetPlayerAchievementStatus;
			#elseif amazon
				GameCircle.onGetPlayerAchievementStatus = onGetPlayerAchievementStatus;
			#elseif ios
				var onGetAchStatus:Dynamic -> Void = function(e:Dynamic) {
					if (onGetPlayerAchievementStatus != null) onGetPlayerAchievementStatus(e.data1, Std.parseInt(e.data2));
				}
				GameCenter.addEventListener(GameCenterEvent.ON_GET_ACHIEVEMENT_STATUS_SUCESS, onGetAchStatus);
			#end
		}
		// -------------------------------------------------------	
	
	public static function getCurrentAchievementSteps(idAchievement:String):Bool {
		#if (android && !amazon)
			return (GooglePlayGames.getCurrentAchievementSteps(idAchievement));
		#elseif amazon
			return (GameCircle.getCurrentAchievementSteps(idAchievement));
		#elseif ios
			GameCenter.getCurrentAchievementSteps(idAchievement);
			return true;
		#else
			return false;
		#end
	}

		// ------------ Callback getCurrentAchievementSteps ------------	
		public static function setOnGetPlayerCurrentSteps(onGetPlayerCurrentSteps:String->Int->Void) {
			#if amazon
				var onGetPlayerCurrentStepsFloat:String -> Float -> Void = function(idAchievement:String, percent:Float){
					var currentSteps = Math.round((percent * totalStepsHash.get(idAchievement)) / 100);
					onGetPlayerCurrentSteps(idAchievement, currentSteps);
				}
				GameCircle.onGetPlayerCurrentSteps = onGetPlayerCurrentStepsFloat;
			#elseif (android && !amazon)
				GooglePlayGames.onGetPlayerCurrentSteps = onGetPlayerCurrentSteps;
			#elseif ios
				var onGetAchSteps:Dynamic -> Void = function(e:Dynamic) {
					if (onGetPlayerCurrentSteps != null) {
						var currentPercent = Std.parseFloat(e.data2);
						var currentSteps = Math.round((currentPercent * totalStepsHash.get(e.data1)) / 100);
						onGetPlayerCurrentSteps(e.data1, currentSteps);
					}
				}
				GameCenter.addEventListener(GameCenterEvent.ON_GET_ACHIEVEMENT_STEPS_SUCESS, onGetAchSteps);
			#end
		}
		// -------------------------------------------------------------

	//////////////////////////////////////////////////////////////////////
	///////////// SCOREBOARDS
	//////////////////////////////////////////////////////////////////////

	public static function displayAllScoreboards(defaultScoreboard:String):Bool {
		#if (android && !amazon)
			return (GooglePlayGames.displayAllScoreboards());
		#elseif amazon
			return (GameCircle.displayAllScoreboards());
		#elseif ios
			GameCenter.showLeaderboard(defaultScoreboard);
			return true;
		#else
			return false;
		#end
	}

	public static function displayScoreboard(idScoreboard:String):Bool {
		#if (android && !amazon)
			return GooglePlayGames.displayScoreboard(idScoreboard);
		#elseif amazon
			return GameCircle.displayScoreboard(idScoreboard);
		#elseif ios
			GameCenter.showLeaderboard(idScoreboard);
			return true;
		#else
			return false;
		#end
	}

	public static function setScore(idScoreboard:String, score:Int):Bool {
		#if (android && !amazon)
			return (GooglePlayGames.setScore(idScoreboard, score));
		#elseif amazon
			return (GameCircle.setScore(idScoreboard, score));
		#elseif ios
			GameCenter.reportScore(idScoreboard, score);
			return true;
		#else
			return false;
		#end
	}

	public static function getPlayerScore(idScoreboard:String):Bool {
		#if (android && !amazon)
			return (GooglePlayGames.getPlayerScore(idScoreboard));
		#elseif amazon
			return (GameCircle.getPlayerScore(idScoreboard));
		#elseif ios
			GameCenter.getPlayerScore(idScoreboard);
			return true;
		#else
			return false;
		#end
	}

		// ------------ Callbacks getPlayerScore ------------
		public static function setOnGetPlayerScore(onGetPlayerScore:String->Int->Void) {
			#if (android && !amazon)
				GooglePlayGames.onGetPlayerScore = onGetPlayerScore;
			#elseif amazon
				GameCircle.onGetPlayerScore = onGetPlayerScore;
			#elseif ios
				var onGetScore:Dynamic -> Void = function(e:Dynamic) {
					if (onGetPlayerScore != null) onGetPlayerScore(e.data1, Std.parseInt(e.data2));
				}
				GameCenter.addEventListener(GameCenterEvent.ON_GET_PLAYER_SCORE_SUCESS, onGetScore);
			#end
		}
		// -------------------------------------------------

	//////////////////////////////////////////////////////////////////////
	///////////// OTHER'S
	//////////////////////////////////////////////////////////////////////

	public static function loadResourcesFromXML(text:String) {
		#if (android && !amazon)
			GooglePlayGames.loadResourcesFromXML(text);
		#end
	}

	///////////////////////////////////////////////////////////////////////////
	//// CLOUD 
	///////////////////////////////////////////////////////////////////////////

	#if amazon
		private static var lastOpenedGame:String = null;
	#end

	public static function loadSavedGame(name:String){
		#if gpgnative
			GooglePlayGames.loadSavedGame(name);
		#elseif amazon
			GameCircle.cloudGet(name);
			lastOpenedGame = name;
		#end
	}

	public static function discardAndCloseGame(){
		#if gpgnative
			GooglePlayGames.discardAndCloseGame();
		#elseif amazon
			lastOpenedGame = null;
		#end
	}

	public static function commitAndCloseGame(data:String,description:String,resolvingConflict:Bool=false){
		#if gpgnative
			GooglePlayGames.commitAndCloseGame(data,description);
		#elseif amazon
			if(lastOpenedGame == null) 
				return;
			GameCircle.cloudSet(lastOpenedGame,data);
			if(resolvingConflict) 
				GameCircle.markConflictAsResolved(lastOpenedGame);
			lastOpenedGame = null;
		#end
	}

	///////////////////////////////////////////////////////////////////////////
	//// CALLBACKS
	///////////////////////////////////////////////////////////////////////////

	public static function setOnLoadGameCompleteCallback(onLoadGameComplete:String->String->Void){
		#if gpgnative
			GooglePlayGames.onLoadGameComplete = onLoadGameComplete;
		#elseif amazon
			GameCircle.onCloudGetComplete = onLoadGameComplete;
		#end
	}

	public static function setOnLoadGameConflictCallback(onLoadGameConflict:String->String->String->Void){
		#if gpgnative
			GooglePlayGames.onLoadGameConflict = onLoadGameConflict;
		#elseif amazon
			GameCircle.onCloudGetConflict = onLoadGameConflict;
		#end
	}

}
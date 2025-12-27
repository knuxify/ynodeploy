-- YNOServer Database Schema for MariaDB
-- Generated based on db.Exec operations from ynoserver codebase

-- Players table - core player information
CREATE TABLE IF NOT EXISTS players (
    uuid VARCHAR(16) NOT NULL PRIMARY KEY,
    ip VARCHAR(45) DEFAULT NULL,
    rank INT NOT NULL DEFAULT 0,
    banned TINYINT(1) NOT NULL DEFAULT 0,
    muted TINYINT(1) NOT NULL DEFAULT 0,
    INDEX idx_ip (ip),
    INDEX idx_banned (banned),
    INDEX idx_muted (muted)
);

-- Accounts table - registered user accounts
CREATE TABLE IF NOT EXISTS accounts (
    uuid VARCHAR(16) NOT NULL PRIMARY KEY,
    ip VARCHAR(45) DEFAULT NULL,
    user VARCHAR(12) NOT NULL UNIQUE,
    pass VARCHAR(255) NOT NULL,
    badge VARCHAR(255) NOT NULL DEFAULT 'null',
    badgeSlotRows INT NOT NULL DEFAULT 1,
    badgeSlotCols INT NOT NULL DEFAULT 3,
    screenshotLimit INT NOT NULL DEFAULT 10,
    inactive TINYINT(1) NOT NULL DEFAULT 0,
    timestampRegistered DATETIME NOT NULL,
    timestampLoggedIn DATETIME DEFAULT NULL,
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE,
    INDEX idx_user (user),
    INDEX idx_inactive (inactive)
);

-- Player sessions - authentication tokens
CREATE TABLE IF NOT EXISTS playerSessions (
    sessionId VARCHAR(32) NOT NULL PRIMARY KEY,
    uuid VARCHAR(16) NOT NULL,
    expiration DATETIME NOT NULL,
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE,
    INDEX idx_uuid (uuid),
    INDEX idx_expiration (expiration)
);

-- Player game data - per-game player information
CREATE TABLE IF NOT EXISTS playerGameData (
    uuid VARCHAR(16) NOT NULL,
    game VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL DEFAULT '',
    systemName VARCHAR(255) NOT NULL DEFAULT '',
    spriteName VARCHAR(255) NOT NULL DEFAULT '',
    spriteIndex INT NOT NULL DEFAULT 0,
    online TINYINT(1) NOT NULL DEFAULT 0,
    timestampLastActive DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    lastGlobalMsgId VARCHAR(12) DEFAULT NULL,
    lastPartyMsgId VARCHAR(12) DEFAULT NULL,
    medalCountBronze INT NOT NULL DEFAULT 0,
    medalCountSilver INT NOT NULL DEFAULT 0,
    medalCountGold INT NOT NULL DEFAULT 0,
    medalCountPlatinum INT NOT NULL DEFAULT 0,
    medalCountDiamond INT NOT NULL DEFAULT 0,
    PRIMARY KEY (uuid, game),
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE,
    INDEX idx_game (game),
    INDEX idx_online (online),
    INDEX idx_lastActive (timestampLastActive)
);

-- Player moderation actions
CREATE TABLE IF NOT EXISTS playerModerationActions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    uuid VARCHAR(16) NOT NULL,
    action INT NOT NULL,
    reason VARCHAR(255) NOT NULL DEFAULT '',
    time DATETIME NOT NULL,
    expiry DATETIME NOT NULL,
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE,
    INDEX idx_uuid_action (uuid, action),
    INDEX idx_expiry (expiry)
);

-- Player blocks
CREATE TABLE IF NOT EXISTS playerBlocks (
    uuid VARCHAR(16) NOT NULL,
    targetUuid VARCHAR(16) NOT NULL,
    timestamp DATETIME NOT NULL,
    PRIMARY KEY (uuid, targetUuid),
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE,
    FOREIGN KEY (targetUuid) REFERENCES players(uuid) ON DELETE CASCADE,
    INDEX idx_timestamp (timestamp)
);

-- Chat messages
CREATE TABLE IF NOT EXISTS chatMessages (
    msgId VARCHAR(12) NOT NULL PRIMARY KEY,
    game VARCHAR(50) NOT NULL,
    uuid VARCHAR(16) NOT NULL,
    mapId VARCHAR(4) NOT NULL,
    prevMapId VARCHAR(4) NOT NULL DEFAULT '',
    prevLocations TEXT DEFAULT NULL,
    x INT NOT NULL DEFAULT 0,
    y INT NOT NULL DEFAULT 0,
    contents TEXT NOT NULL,
    partyId INT DEFAULT NULL,
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE,
    INDEX idx_game (game),
    INDEX idx_timestamp (timestamp),
    INDEX idx_party (partyId)
);

-- Game locations
CREATE TABLE IF NOT EXISTS gameLocations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    game VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    titleJP VARCHAR(255) DEFAULT NULL,
    depth INT NOT NULL DEFAULT 0,
    minDepth INT NOT NULL DEFAULT 0,
    mapIds JSON NOT NULL,
    secret TINYINT(1) NOT NULL DEFAULT 0,
    UNIQUE KEY unique_game_title (game, title),
    INDEX idx_game (game),
    INDEX idx_secret (secret)
);

-- Player game locations
CREATE TABLE IF NOT EXISTS playerGameLocations (
    uuid VARCHAR(16) NOT NULL,
    locationId INT NOT NULL,
    timestamp DATETIME NOT NULL,
    PRIMARY KEY (uuid, locationId),
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE,
    FOREIGN KEY (locationId) REFERENCES gameLocations(id) ON DELETE CASCADE,
    INDEX idx_locationId (locationId)
);

-- Event periods
CREATE TABLE IF NOT EXISTS eventPeriods (
    id INT AUTO_INCREMENT PRIMARY KEY,
    periodOrdinal INT NOT NULL,
    startDate DATE NOT NULL,
    endDate DATE NOT NULL,
    INDEX idx_dates (startDate, endDate)
);

-- Game event periods
CREATE TABLE IF NOT EXISTS gameEventPeriods (
    id INT AUTO_INCREMENT PRIMARY KEY,
    periodId INT NOT NULL,
    game VARCHAR(50) NOT NULL,
    enableVms TINYINT(1) NOT NULL DEFAULT 0,
    FOREIGN KEY (periodId) REFERENCES eventPeriods(id) ON DELETE CASCADE,
    UNIQUE KEY unique_period_game (periodId, game),
    INDEX idx_game (game)
);

-- Event locations
CREATE TABLE IF NOT EXISTS eventLocations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    locationId INT NOT NULL,
    gamePeriodId INT NOT NULL,
    type INT NOT NULL DEFAULT 0,
    exp INT NOT NULL DEFAULT 0,
    startDate DATE NOT NULL,
    endDate DATE NOT NULL,
    FOREIGN KEY (locationId) REFERENCES gameLocations(id) ON DELETE CASCADE,
    FOREIGN KEY (gamePeriodId) REFERENCES gameEventPeriods(id) ON DELETE CASCADE,
    INDEX idx_dates (startDate, endDate),
    INDEX idx_type (type)
);

-- Player event locations
CREATE TABLE IF NOT EXISTS playerEventLocations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    locationId INT NOT NULL,
    gamePeriodId INT NOT NULL,
    uuid VARCHAR(16) NOT NULL,
    startDate DATE NOT NULL,
    endDate DATE NOT NULL,
    FOREIGN KEY (locationId) REFERENCES gameLocations(id) ON DELETE CASCADE,
    FOREIGN KEY (gamePeriodId) REFERENCES gameEventPeriods(id) ON DELETE CASCADE,
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE,
    INDEX idx_dates (startDate, endDate),
    INDEX idx_uuid (uuid)
);

-- Player event location queue
CREATE TABLE IF NOT EXISTS playerEventLocationQueue (
    game VARCHAR(50) NOT NULL,
    date DATE NOT NULL,
    queueIndex INT NOT NULL,
    locationId INT NOT NULL,
    PRIMARY KEY (game, date, queueIndex),
    FOREIGN KEY (locationId) REFERENCES gameLocations(id) ON DELETE CASCADE
);

-- Event VMs
CREATE TABLE IF NOT EXISTS eventVms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    gamePeriodId INT NOT NULL,
    mapId INT NOT NULL,
    eventIds JSON NOT NULL,
    exp INT NOT NULL DEFAULT 0,
    startDate DATE NOT NULL,
    endDate DATE NOT NULL,
    FOREIGN KEY (gamePeriodId) REFERENCES gameEventPeriods(id) ON DELETE CASCADE,
    INDEX idx_dates (startDate, endDate),
    INDEX idx_map (mapId)
);

-- Event completions
CREATE TABLE IF NOT EXISTS eventCompletions (
    eventId INT NOT NULL,
    uuid VARCHAR(16) NOT NULL,
    type INT NOT NULL,
    timestampCompleted DATETIME NOT NULL,
    exp INT NOT NULL DEFAULT 0,
    PRIMARY KEY (eventId, uuid, type),
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE,
    INDEX idx_timestamp (timestampCompleted)
);

-- Player tags
CREATE TABLE IF NOT EXISTS playerTags (
    uuid VARCHAR(16) NOT NULL,
    name VARCHAR(255) NOT NULL,
    timestampUnlocked DATETIME NOT NULL,
    PRIMARY KEY (uuid, name),
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE,
    INDEX idx_timestamp (timestampUnlocked)
);

-- Player time trials
CREATE TABLE IF NOT EXISTS playerTimeTrials (
    uuid VARCHAR(16) NOT NULL,
    mapId INT NOT NULL,
    seconds INT NOT NULL,
    timestampCompleted DATETIME NOT NULL,
    PRIMARY KEY (uuid, mapId),
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE,
    INDEX idx_timestamp (timestampCompleted)
);

-- Badges
CREATE TABLE IF NOT EXISTS badges (
    badgeId VARCHAR(255) NOT NULL PRIMARY KEY,
    game VARCHAR(50) NOT NULL,
    bp INT NOT NULL DEFAULT 0,
    hidden TINYINT(1) NOT NULL DEFAULT 0,
    percentUnlocked FLOAT NOT NULL DEFAULT 0,
    INDEX idx_game (game)
);

-- Player badges
CREATE TABLE IF NOT EXISTS playerBadges (
    uuid VARCHAR(16) NOT NULL,
    badgeId VARCHAR(255) NOT NULL,
    slotRow INT NOT NULL DEFAULT 0,
    slotCol INT NOT NULL DEFAULT 0,
    timestampUnlocked DATETIME NOT NULL,
    PRIMARY KEY (uuid, badgeId),
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE,
    INDEX idx_slot (uuid, slotRow, slotCol),
    INDEX idx_timestamp (timestampUnlocked)
);

-- Player badge presets
CREATE TABLE IF NOT EXISTS playerBadgePresets (
    uuid VARCHAR(16) NOT NULL,
    presetId INT NOT NULL,
    data TEXT DEFAULT NULL,
    PRIMARY KEY (uuid, presetId),
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE
);

-- Player minigame scores
CREATE TABLE IF NOT EXISTS playerMinigameScores (
    uuid VARCHAR(16) NOT NULL,
    game VARCHAR(50) NOT NULL,
    minigameId VARCHAR(255) NOT NULL,
    score INT NOT NULL,
    timestampCompleted DATETIME NOT NULL,
    PRIMARY KEY (uuid, game, minigameId),
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE,
    INDEX idx_game (game)
);

-- Parties
CREATE TABLE IF NOT EXISTS parties (
    id INT AUTO_INCREMENT PRIMARY KEY,
    game VARCHAR(50) NOT NULL,
    owner VARCHAR(16) NOT NULL,
    name VARCHAR(255) NOT NULL,
    public TINYINT(1) NOT NULL DEFAULT 0,
    pass VARCHAR(255) NOT NULL DEFAULT '',
    theme VARCHAR(255) NOT NULL DEFAULT '',
    description TEXT DEFAULT NULL,
    FOREIGN KEY (owner) REFERENCES players(uuid) ON DELETE CASCADE,
    INDEX idx_game (game),
    INDEX idx_public (public)
);

-- Party members
CREATE TABLE IF NOT EXISTS partyMembers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    partyId INT NOT NULL,
    uuid VARCHAR(16) NOT NULL,
    FOREIGN KEY (partyId) REFERENCES parties(id) ON DELETE CASCADE,
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE,
    UNIQUE KEY unique_party_member (partyId, uuid),
    INDEX idx_uuid (uuid)
);

-- Player friends
CREATE TABLE IF NOT EXISTS playerFriends (
    uuid VARCHAR(16) NOT NULL,
    targetUuid VARCHAR(16) NOT NULL,
    accepted TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (uuid, targetUuid),
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE,
    FOREIGN KEY (targetUuid) REFERENCES players(uuid) ON DELETE CASCADE,
    INDEX idx_target (targetUuid),
    INDEX idx_accepted (accepted)
);

-- Schedules
CREATE TABLE IF NOT EXISTS schedules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT DEFAULT NULL,
    ownerUuid VARCHAR(16) NOT NULL,
    partyId INT DEFAULT NULL,
    game VARCHAR(50) NOT NULL,
    official TINYINT(1) NOT NULL DEFAULT 0,
    recurring TINYINT(1) NOT NULL DEFAULT 0,
    intervalValue INT DEFAULT NULL,
    intervalType VARCHAR(20) DEFAULT NULL,
    datetime DATETIME NOT NULL,
    systemName VARCHAR(255) DEFAULT NULL,
    discord VARCHAR(255) DEFAULT NULL,
    youtube VARCHAR(255) DEFAULT NULL,
    twitch VARCHAR(255) DEFAULT NULL,
    niconico VARCHAR(255) DEFAULT NULL,
    openrec VARCHAR(255) DEFAULT NULL,
    bilibili VARCHAR(255) DEFAULT NULL,
    FOREIGN KEY (ownerUuid) REFERENCES players(uuid) ON DELETE CASCADE,
    FOREIGN KEY (partyId) REFERENCES parties(id) ON DELETE SET NULL,
    INDEX idx_game (game),
    INDEX idx_datetime (datetime),
    INDEX idx_owner (ownerUuid)
);

-- Player schedule follows
CREATE TABLE IF NOT EXISTS playerScheduleFollows (
    uuid VARCHAR(16) NOT NULL,
    scheduleId INT NOT NULL,
    PRIMARY KEY (uuid, scheduleId),
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE,
    FOREIGN KEY (scheduleId) REFERENCES schedules(id) ON DELETE CASCADE
);

-- Game player counts
CREATE TABLE IF NOT EXISTS gamePlayerCounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    game VARCHAR(50) NOT NULL,
    playerCount INT NOT NULL,
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_game (game),
    INDEX idx_timestamp (timestamp)
);

-- Game save data
CREATE TABLE IF NOT EXISTS gameSaveData (
    uuid VARCHAR(16) NOT NULL PRIMARY KEY,
    data MEDIUMBLOB NOT NULL,
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE,
    INDEX idx_timestamp (timestamp)
);

-- Player reports
CREATE TABLE IF NOT EXISTS playerReports (
    uuid VARCHAR(16) NOT NULL,
    targetUuid VARCHAR(16) NOT NULL,
    msgId VARCHAR(12) DEFAULT NULL,
    game VARCHAR(50) NOT NULL,
    reason TEXT NOT NULL,
    originalMsg TEXT DEFAULT NULL,
    timestampReported DATETIME NOT NULL,
    actionTaken TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (uuid, targetUuid, msgId),
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE,
    FOREIGN KEY (targetUuid) REFERENCES players(uuid) ON DELETE CASCADE,
    INDEX idx_target (targetUuid),
    INDEX idx_action (actionTaken)
);

-- Push subscriptions (web push notifications)
CREATE TABLE IF NOT EXISTS pushSubscriptions (
    uuid VARCHAR(16) NOT NULL,
    endpoint VARCHAR(512) NOT NULL,
    p256dh VARCHAR(255) NOT NULL,
    auth VARCHAR(255) NOT NULL,
    PRIMARY KEY (uuid, endpoint),
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE
);

-- Player screenshots
CREATE TABLE IF NOT EXISTS playerScreenshots (
    id VARCHAR(16) NOT NULL PRIMARY KEY,
    uuid VARCHAR(16) NOT NULL,
    game VARCHAR(50) NOT NULL,
    mapId VARCHAR(4) NOT NULL,
    mapX INT NOT NULL DEFAULT 0,
    mapY INT NOT NULL DEFAULT 0,
    public TINYINT(1) NOT NULL DEFAULT 0,
    publicTimestamp DATETIME DEFAULT NULL,
    spoiler TINYINT(1) NOT NULL DEFAULT 0,
    temp TINYINT(1) NOT NULL DEFAULT 0,
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE,
    INDEX idx_game (game),
    INDEX idx_public (public),
    INDEX idx_temp (temp),
    INDEX idx_timestamp (timestamp),
    INDEX idx_publicTimestamp (publicTimestamp)
);

-- Player screenshot likes
CREATE TABLE IF NOT EXISTS playerScreenshotLikes (
    screenshotId VARCHAR(16) NOT NULL,
    uuid VARCHAR(16) NOT NULL,
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (screenshotId, uuid),
    FOREIGN KEY (screenshotId) REFERENCES playerScreenshots(id) ON DELETE CASCADE,
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE,
    INDEX idx_timestamp (timestamp)
);

-- Yume 2kki API query cache
CREATE TABLE IF NOT EXISTS 2kkiApiQueries (
    action VARCHAR(255) NOT NULL,
    query TEXT NOT NULL,
    response MEDIUMTEXT NOT NULL,
    timestampExpired DATETIME NOT NULL,
    PRIMARY KEY (action, query(255)),
    INDEX idx_expiry (timestampExpired)
);

-- Wiki API query cache
CREATE TABLE IF NOT EXISTS wikiApiQueries (
    game VARCHAR(50) NOT NULL,
    action VARCHAR(255) NOT NULL,
    query TEXT NOT NULL,
    response MEDIUMTEXT NOT NULL,
    timestampExpired DATETIME NOT NULL,
    PRIMARY KEY (game, action, query(255)),
    INDEX idx_expiry (timestampExpired)
);

-- Rankings (ynorankings)

CREATE TABLE IF NOT EXISTS rankingCategories (
    categoryId VARCHAR(100) NOT NULL,
    game VARCHAR(50) NOT NULL DEFAULT '',
    ordinal INT NOT NULL,
    periodic TINYINT(1) DEFAULT 0,
    PRIMARY KEY (categoryId, game)
);

CREATE TABLE IF NOT EXISTS rankingSubCategories (
    categoryId VARCHAR(100) NOT NULL,
    subCategoryId VARCHAR(100) NOT NULL,
    game VARCHAR(50) NOT NULL DEFAULT '',
    ordinal INT NOT NULL,
    active TINYINT(1) DEFAULT 1,
    PRIMARY KEY (categoryId, subCategoryId, game)
);

CREATE TABLE IF NOT EXISTS rankingEntries (
    categoryId VARCHAR(100) NOT NULL,
    subCategoryId VARCHAR(100) NOT NULL,
    position INT NOT NULL,
    actualPosition INT NOT NULL,
    uuid VARCHAR(16) NOT NULL,
    valueInt INT,
    valueFloat FLOAT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (categoryId, subCategoryId, position, timestamp),
    FOREIGN KEY (uuid) REFERENCES players(uuid) ON DELETE CASCADE
);

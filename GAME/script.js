// --- Game Balance Data (Updated from Feedback) ---
const PLAYER_CONFIG = {
    baseHP: 150, // Increased HP
    baseHPRegen: 0.5, // Small passive regen per second
    baseMoveSpeed: 2.2, // Slightly slower base speed
    baseDefense: 5, // Base damage reduction
    slashRange: 70,
    baseAttackSpeed: 1.0, // Delay multiplier (1.0 = normal, lower is faster)
    invulnerabilityWindow: 1.0 // Seconds of invul after being hit
};

// Zombie configuration: Buffed durability, nerfed speed for Common/Uncommon
const ZOMBIE_TYPES = {
    common: { hp: 40, damage: 15, speed: 0.8, xp: 5, color: '#55aa55' }, // 40% slower
    uncommon: { hp: 110, damage: 25, speed: 1.0, xp: 15, color: '#3498db' }, // 30% slower
    special: { hp: 350, damage: 50, speed: 1.6, xp: 50, color: '#9b59b6' }, 
    boss: { hp: 2500, damage: 100, speed: 1.2, xp: 300, color: '#e74c3c' } 
};

// The 15+ Unique Abilities System
const abilityPool = [
    // --- Your original requested Abilities (updated for scaling) ---
    { id: 'atk_speed', name: 'Rapid Fire', type: 'passive', desc: 'Boosts attack speed by 15%', maxLvl: 5 },
    { id: 'agility', name: 'Sprint', type: 'passive', desc: 'Increases movement speed by 10%', maxLvl: 5 },
    { id: 'endurance', name: 'Plating', type: 'passive', desc: 'Reduces incoming damage by 4', maxLvl: 5 },
    { id: 'toughness', name: 'Might', type: 'passive', desc: 'Increases damage dealt by 20%', maxLvl: 5 },
    { id: 'evasion', name: 'Reflexes', type: 'passive', desc: 'Increases dodge chance by 8%', maxLvl: 5 },
    { id: 'chill_cd', name: 'Coolant', type: 'passive', desc: 'Reduces skill cooldowns by 15%', maxLvl: 5 },
    { id: 'tantrum', name: 'Tantrum', type: 'active', desc: 'Gain extreme speed/strength (60s Duration, 2min CD)', maxLvl: 1 },
    { id: 'vengeance', name: 'Thorns', type: 'passive', desc: 'Reflects 30% of damage taken back to the attacker', maxLvl: 3 },
    
    // --- New Unique Scaling Skills (Balanced) ---
    { id: 'lifesteal', name: 'Vampirism', type: 'passive', desc: 'Heals you for 5% of damage dealt', maxLvl: 5 },
    { id: 'range', name: 'Longshot', type: 'passive', desc: 'Increases attack/slash range by 20%', maxLvl: 5 },
    { id: 'crit', name: 'Precision', type: 'passive', desc: 'Grants 10% critical hit chance (2x Damage)', maxLvl: 5 },
    { id: 'pierce', name: 'Pierce', type: 'weapon_mod', desc: 'Projectiles pierce through 1 extra enemy', maxLvl: 3 },
    { id: 'magnet', name: 'Magnetism', type: 'utility', desc: 'Increases XP pickup range by 50%', maxLvl: 3 },
    { id: 'vitality', name: 'Regen', type: 'passive', desc: 'Increases passive HP regen by 1.0/s', maxLvl: 3 },
    { id: 'aoe_slash', name: 'Greater Cleave', type: 'passive', desc: 'Increases slash attack area width by 30%', maxLvl: 5 }
];

// Player state variables for tracking new systems
player.lastHitTime = 0; // For invulnerability window
player.invulnerable = false;
player.hpRegen = PLAYER_CONFIG.baseHPRegen;
player.lifestealPercent = 0.0;
player.critChance = 0.0;
player.damageBoost = 1.0;
player.pierceCount = 0;
player.xpPickupRange = 100;
player.slashing = false; // Prevents overlapping effects

// ... continuing Java (part 2 implementation) ...

// Function to handle taking damage with proper invulnerability window
function playerTakeDamage(zombieType) {
    if (player.invulnerable) return;

    const damageData = ZOMBIE_TYPES[zombieType];
    const defense = player.abilities.endurance * 4 + PLAYER_CONFIG.baseDefense; // Endurance skill scales
    
    // Final Damage calculation (ensuring it's not negative)
    let finalDamage = Math.max(1, damageData.damage - defense);
    
    // Simple Evasion check
    if (player.abilities.evasion > 0) {
        if (Math.random() < (player.abilities.evasion * 0.08)) {
            showFloatingText('DODGE!', player.x, player.y - 30, 'norm-damage');
            return; // No damage taken
        }
    }
    
    player.hp -= finalDamage;
    updatePlayerHPBar();
    showFloatingText(`-${finalDamage}`, player.x, player.y - 20, 'player-damage');
    
    // Set invulnerability
    player.invulnerable = true;
    player.lastHitTime = gameTime;
    
    if (player.hp <= 0) {
        // Handle Game Over
    }
}

// Function to handle the passive HP regeneration
function applyPlayerRegen(deltaTime) {
    if (player.hp > 0 && player.hp < player.maxHP) {
        let regenAmount = player.hpRegen * deltaTime;
        player.hp = Math.min(player.maxHP, player.hp + regenAmount);
        updatePlayerHPBar(); // Smooth update
    }
    
    // Check if invulnerability window is over
    if (player.invulnerable && (gameTime - player.lastHitTime) > PLAYER_CONFIG.invulnerabilityWindow) {
        player.invulnerable = false;
    }
}

// Function to trigger the visual slash effect indicating attack range
function performSlashAttack() {
    if (player.slashing) return; // Prevent spamming before animation finishes
    
    player.slashing = true;
    
    const range = PLAYER_CONFIG.slashRange * (1 + player.abilities.range * 0.2); // Scaling range
    
    // Generate Slash VFX
    const slash = document.createElement('div');
    slash.className = 'slash-effect';
    slash.style.width = `${range * 2}px`;
    slash.style.height = `${range * 2}px`;
    slash.style.left = `${player.x - range}px`;
    slash.style.top = `${player.y - range}px`;
    
    gameScreen.appendChild(slash);
    
    // Cleanup VFX
    setTimeout(() => {
        slash.remove();
        player.slashing = false;
    }, 300); // Matches CSS animation duration
}

// Function to handle dealt damage, implementing Crit, Life Steal, and Vengeance
function dealDamageToZombie(zombie, damageAmount, isProjectile = false) {
    let finalDamage = damageAmount * player.damageBoost;
    let isCrit = false;
    
    // Critical Strike Check
    if (player.abilities.crit > 0 && Math.random() < (player.abilities.crit * 0.1)) {
        finalDamage *= 2;
        isCrit = true;
    }
    
    finalDamage = Math.round(finalDamage);
    zombie.hp -= finalDamage;
    
    // Show Damage Numbers
    const textClass = isCrit ? 'crit-damage' : 'norm-damage';
    showFloatingText(`${finalDamage}${isCrit ? '!' : ''}`, zombie.x, zombie.y - 20, textClass);
    
    // Life Steal Implementation
    if (player.lifestealPercent > 0 && player.hp < player.maxHP) {
        let healAmount = Math.min(1, finalDamage * player.lifestealPercent); // Cap single instance heal
        player.hp = Math.min(player.maxHP, player.hp + healAmount);
        updatePlayerHPBar();
    }
    
    if (zombie.hp <= 0) {
        killZombie(zombie);
    }
}

// Utility: Generate floating text VFX
function showFloatingText(text, x, y, typeClass) {
    const textEl = document.createElement('div');
    textEl.className = `damage-num ${typeClass}`;
    textEl.innerText = text;
    textEl.style.left = `${x}px`;
    textEl.style.top = `${y}px`;
    
    damageTextContainer.appendChild(textEl);
    
    // Automatic cleanup
    setTimeout(() => textEl.remove(), 800);
}
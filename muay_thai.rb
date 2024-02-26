require 'ruby2d'

# Set window title, width, and height
set title: "Thai fighter", width: 960, height: 536

# Load background image
background = Image.new("img/thai_fighter_map_1.jpg", width: 960, height: 536)

# Function to load character sprites
def load_character_sprites
  # Load standing sprite
  standing_sprite = Sprite.new(
    'img/sprite_standing.png',
    clip_width: 74,
    clip_height: 121,
    time: 310,
    loop: true
  )

  # Load movement sprite
  movement_sprite = Sprite.new(
    'img/sprite_walk.png',
    clip_width: 71,
    clip_height: 124,
    time: 140,
    loop: true
  )

  # Load kick sprite
  kick_sprite = Sprite.new(
    'img/sprite_kick.png',
    clip_width: 131,
    clip_height: 125,
    time: 260,
    loop: false,
  )

  character_sprite = [standing_sprite, movement_sprite, kick_sprite]

  # Set initial positions and dimensions for character sprites
  character_sprite.each do |sprite|
    sprite.width = 110
    sprite.height = 165
    sprite.x = 250
    sprite.y = 340
    sprite.remove
  end

  # Adjust width for kick sprite
  character_sprite[2].width = 180

  return character_sprite
end

character_sprite = load_character_sprites

# Start the standing animation loop
character_sprite[0].add
character_sprite[0].play

# Function to remove character sprites
def remove_character_sprites(character_sprite)
  character_sprite.each do |sprite|
    sprite.remove
  end
  kicking_active = 0
end

# Initialize direction as a global variable
$direction = -1

# Define handle_character_movement function
def handle_character_movement(character_sprite)
  on :key_down do |event|
    case event.key
    when 'left'
      remove_character_sprites(character_sprite)
      character_sprite[1].add
      character_sprite[1].play(flip: :horizontal)
      $direction = -1
      puts $direction
    when 'right'
      remove_character_sprites(character_sprite)
      character_sprite[1].add
      character_sprite[1].play
      $direction = 1
    end
  end

  on :key_up do |event|
    case event.key
    when 'left', 'right'
      remove_character_sprites(character_sprite)
      character_sprite[0].add
      
      if $direction < 0
          character_sprite[0].play(flip: :horizontal)
      else
          character_sprite[0].play
      end
      $kicking_active = 0
    end
  end

  on :key_held do |event|
    case event.key
    when 'left'
      character_sprite[1].x -= 3
    when 'right'
      character_sprite[1].x += 3
    end

    character_sprite[0].x = character_sprite[1].x
    character_sprite[0].y = character_sprite[1].y
  end
end

# Continuous output of kicking_active and direction every second
Thread.new do
  loop do
    puts "Kicking Active: #{$kicking_active}, Direction: #{$direction}"
    sleep(1)
  end
end

$kicking_active = 0

# Define handle_fighting_animations function
def handle_fighting_animations(character_sprite)
  on :key_held do |event|
    case event.key
    when 'r', 'R'
      puts $direction
      remove_character_sprites(character_sprite)
      character_sprite[2].x = character_sprite[1].x
      character_sprite[2].y = character_sprite[1].y
      character_sprite[2].add
      if $direction < 0
        character_sprite[2].play flip: :horizontal
      else
        character_sprite[2].play
      end
      $kicking_active = 1
    end
  end
end

# Call handle_character_movement
handle_character_movement(character_sprite)

# Call handle_fighting_animations
handle_fighting_animations(character_sprite)

# Function to initialize missile sprites
missile_sprites = []
missile_speeds = []

5.times do
  # Load missile sprite
  missile = Sprite.new(
    'img/sprite_missile.png',
    clip_width: 85,
    clip_height: 39,
    time: 500,
    loop: true
  )
  missile_sprites << missile

  # Set initial speed for each missile
  missile_speeds << 3
end

# Set initial position and dimensions for each missile sprite
missile_sprites.each do |missile|
  missile.width = 85
  missile.height = 39
  missile.y = rand(Window.height)
end

# Function to check if missile coordinates overlap with character position
def missile_coordinates_overlap_character?(missile, character_sprite)
  character_sprite.each_with_index do |sprite, index|
    next if index == 2 # Skip the kicking sprite
    if missile.x >= sprite.x && missile.x <= sprite.x + sprite.width &&
       missile.y >= sprite.y && missile.y <= sprite.y + sprite.height
      return true
    end
  end
  false
end

# Function to update missile sprites
def update_missile_sprites(missile_sprites, missile_speeds, character_sprite)
  times_run = 0
  points = 0
  lives = 3
  update do
    missile_sprites.each_with_index do |missile, index|
      # Move all missile sprites
      missile.x += missile_speeds[index]
      
      # Check if missile overlaps with character sprites except kicking sprite
      if missile_coordinates_overlap_character?(missile, character_sprite)
        if $kicking_active == 1
          points += 1 # Increment points if kicking_active is 1
        else
          lives -= 1 # Decrement lives if kicking_active is 0
        end
        if rand(2) + 1 == 1
          missile_speeds[index] = -3
          missile.play flip: :horizontal
          times_run += 1
        else
          # Reset the position and speed of the missile
          missile.x = -Window.width
          missile_speeds[index] = 3
          missile.play
          times_run += 1
        end
        missile.y = rand(Window.height)
      end
      
      # Adjust the speed of the missile by changing the increment value
      # Check if the missile goes off-screen to the right
      if missile.x > Window.width
        if rand(2) + 1 == 1
          missile_speeds[index] = -3
          missile.play flip: :horizontal
          times_run += 1
        else
          # Reset the position and speed of the missile
          missile.x = -Window.width
          missile_speeds[index] = 3
          missile.play
          times_run += 1
        end
        missile.y = rand(Window.height)
      elsif missile.x < 0  # Check if the missile goes off-screen to the left
        if rand(2) + 1 == 1
          missile.x += Window.width  # Move the missile to the right side of the window
          missile_speeds[index] = -3
          missile.play flip: :horizontal
          times_run += 1
        else
          missile_speeds[index] = 3
          missile.play
          times_run += 1
        end
        missile.y = rand(Window.height)
      end
      if times_run == 0
        missile.play
      end
      if points == 10
        puts "du vann" # You won
        sleep(0.1)
        close
      end
      if lives <= 0
        puts "du förlora" # You lost
        sleep(0.1)
        close
      end
    end
  end
end

#handles so you can't walk out of the viewport
def handle_map_boundary(character_sprite)
  on :key_held do |event|
    case event.key
    when 'left'
      if character_sprite[1].x <= 0
        character_sprite[1].x = 0
      end
    when 'right'
      if character_sprite[1].x + character_sprite[1].width >= Window.width
        character_sprite[1].x = Window.width - character_sprite[1].width
      end
    end
  end
end


# Continuous output of kicking_active every second
Thread.new do
  loop do
    puts "Kicking Active: #{$kicking_active}"
    sleep(1)
  end
end

# Update the function call to include character_sprite argument
handle_character_movement(character_sprite)
handle_map_boundary(character_sprite)
update_missile_sprites(missile_sprites, missile_speeds, character_sprite)


# Display the window
show

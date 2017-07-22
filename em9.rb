# Em9
# ***
# Coded by Ard Vank with Sonic Pi v2.10

use_bpm 60
use_debug false


# INDEX
# *****

# FUNCTIONS
# =========
# guitar glitch drone function
# bass function
# guitar loop drone function
# pad mid function (:dark_ambience)
# pad hi function (:hollow)
# extra pad function

# Music starts here
# =================
# counting measures
# guitar glitch drone
# guitar loop drone (2 measures)
# bass (2 measures)
# pad mid (2 measures)
# pad hi (2 measures)
# pad extra
# ride



# FUNCTIONS
# =========

# guitar glitch drone function
# ----------------------------
define :glitch_player do |sample_name|
  glitch_length = rrand(0.03, 0.15)
  start_point = rand
  
  if one_in(3)
    finish_point = start_point + glitch_length
    if finish_point > 1
      finish_point = 1
    end
  else
    finish_point = start_point - glitch_length # reversed
    if finish_point < 0
      finish_point = 0.03
    end
  end
  
  with_fx :reverb do |r|
    control r, mix: rrand(0, 1), room: rrand(0, 1)
    
    with_fx :echo do |e|
      control e, phase: [0.33, 0.5, 0.66].choose,
        decay: 3, mix: rrand(0.2, 0.7)
      
      sample sample_name, start: start_point, finish: finish_point,
        cutoff: rrand(90, 90),
        amp: 1.5, attack: 0.05, release: 0.4, pan: rrand(-0.5, 0.3)
    end
  end
  sleep glitch_length
end


# bass function
# -------------
define :bass do |n|
  use_synth :beep
  
  play n, attack: rrand(0.01, 0.25),
    sustain: rrand(0.01, 0.3),
    decay: rrand(0.2, 0.35),
    amp: 0.3
end


# guitar loop drone function
# ---------------------------
define :guit_loop_drone do |voice, vowel|
  with_fx :lpf, cutoff: rrand(95, 120) do
    with_fx :vowel, voice: voice, vowel_sound: vowel do
      if one_in(2)
        sample :guit_em9, start: 1, finish: 0,
          amp: 0.3, pan: rrand(0, 0.4) # reversed
      else
        sample :guit_em9, start: 0, finish: 1,
          amp: 0.25, pan: rrand(0, 0.4)
      end
    end
  end
end

#  Combination of voice and vowel_sound give
#  different resonant notes
#
#             vowel_sound
#         1    2    3    4    5
#  voice  ---------------------
#    0    g    f    c    a#   f
#    1    f#   c    a#   f    g
#    2    c#   a#   f    d    g
#    3    a#   f    g    g    f
#    4    e    g    g    f    a#


# pad mid function (:dark_ambience)
# ----------------
define :padmid do |dur, noot|
  attack_value = rrand(0.5, 1) * dur
  release_value = 2.25
  with_fx :hpf, cutoff: 60 do
    play noot, pan: 0,
      env_curve: 1, detune1: 12.05, ring: 0.8,
      attack: attack_value, release: release_value,
      cutoff: rrand(60, 105), amp: 0.4
  end
  sleep dur
end


# pad hi function (:hollow)
# -----------------
define :padhi do |dur, noot|
  attack_value = rrand(0.75, 1) * dur
  release_value = 2.25
  with_fx :hpf, cutoff: 70 do
    play noot, pan: rrand(-0.8, 0.8),
      env_curve: 1,
      attack: attack_value, release: release_value,
      cutoff: rrand(60, 105), amp: 0.9
  end
  sleep dur
end

# extra pad function
# ------------------
define :padextra do |dur, noot|
  attack_value = rrand(0.75, 1) * dur
  release_value = 2.25
  with_fx :hpf, cutoff: 80 do
    play noot, pan: [-0.8, -0.7, 0.7, 0.8].choose,
      env_curve: 1,
      attack: attack_value, release: release_value,
      cutoff: rrand(60, 105), amp: 0.8
  end
  sleep dur
end


# =================
# Music starts here
# =================
use_random_seed 2150

# count in, for syncing seperate recordings
#4.times do
#sample :elec_tick
#sleep 1
#end


# counting measures
$measure = 0
in_thread do
  loop do
    cue :master
    $measure += 1
    puts "measure = #{$measure}"
    sleep 4
  end
end


# guitar glitch drone
in_thread do
  loop do
    n = note(:E5) # bpf frequency as note
    with_fx :bpf, centre: n, res: 0.9, amp: rrand(0.5, 0.75) do
      glitch_player :guit_em9
      if ($measure > 12) # when the bass starts
        sleep 0.25
      else
        sleep 0.5
      end
    end
    if ($measure > 77)
      stop
    end
  end
end


# guitar loop drone (2 measures)
in_thread do
  loop do
    sync :master
    if ($measure > 77)
      stop
    end
    
    guit_loop_drone 4,1  # E
    sleep 4
    guit_loop_drone 2,4  # D
    sleep 2
    guit_loop_drone 2,1  # Cis
    sleep 2
  end
end

sleep 12*4

use_random_seed 55555

# measure 13

# bass (2 measures)
in_thread do
  loop do
    sync :master
    if ($measure > 75)
      stop
    end
    
    bass :E2
    sleep 2
    
    bass [:E2, :G1, :B1].choose
    sleep 2
    
    bass :D2
    sleep 2
    if ($measure != 36)
      bass :A1
      if one_in(2)
        sleep 2
      else
        sleep 0.75
        bass :A1
        sleep 1.25
      end
    else
      sleep 2
    end
  end
end


sleep 4*4
use_random_seed 33334
sleep 4*4

# measure 21

# pad mid (2 measures)
in_thread do
  loop do
    sync :master
    if ($measure > 73)
      stop
    end
    
    use_synth :dark_ambience
    
    # measure 1
    if one_in(2)
      padmid 4, :G3
    else
      padmid 3, :G3
      padmid 1, :B3
    end
    
    # measure 2
    padmid 2, :A3
    padmid 2, [:E3, :Fs3].choose
  end
end


# pad hi (2 measures)
in_thread do
  loop do
    sync :master
    if ($measure > 73)
      stop
    end
    
    use_synth :hollow
    
    padhi 4, [:E5, :G5, :E4].choose
    padhi 2, [:D5, :A4, :D4].choose
    padhi 2, [:Cs5, :Cs4, :Cs4 ].choose
  end
end

sleep 16*4

# measure 37

# pad extra
in_thread do
  loop do
    
    use_synth :hollow
    
    sync :master
    if ($measure > 69)
      stop
    end
    with_fx :echo do |g|
      control g, phase: [0.33, 0.5, 0.66, 1.25].choose,
        decay: 3, mix: rrand(0.5, 0.7)
      
      padextra 2, [:B5, :E5,].choose
      padextra 2, [:E5, :B5,].choose
      
      padextra 2, [:G5, :D5].choose
      padextra 2, [:A5, :Cs5].choose
      
    end
  end
end


# ride
skip_ride_beats = [206]

in_thread do
  loop do
    if ($measure > 76)
      stop
    end
    # puts "ride counter:  #{beat}"
    if !skip_ride_beats.include?(beat)
      
      sample :drum_cymbal_soft, attack: rrand(0, 0.02),
        rate: rrand(2, 2.04), amp: ring(0.05, 0.07, 0.05, 0.06).tick
    end
    sleep 1
  end
end




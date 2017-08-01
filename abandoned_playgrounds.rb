# Abandoned playgrounds
# *********************
# Coded by Ard Vank with Sonic Pi v2.10

# INDEX
# *****
# FUNCTIONS
# bass_drone_function
# pad_function
# fm_stab_function
# geiger_function
# one_shot_function
# random_global_sleep_function
# stop_after_measure_function

# Music starts here
# -----------------
# counting_measures
# kick
# bass_drone
# fm_stab
# hihat_geiger
# elec_snare_trumpet
# dragon_fire
# low_drum_hit
# bowed_synth
# pad


# FUNCTIONS
#-----------
# bass_drone_function
# -------------------
define :bsdrone do |n|
  n = n-1
  with_fx :reverb, mix: 1, room: 1 do
    with_fx :tanh do
      with_fx :lpf, cutoff: 60 do
        attack_value = rrand(0.5, 1)
        release_value = rrand(2, 3)
        play n, pan: rrand(0.2, 0.9),
          attack: attack_value, release: release_value,
          amp: 2
        # doubled and detuned
        play n+rrand(0, 0.45), pan: rrand(0.2, 0.9),
          attack: attack_value+0.3, release: release_value+0.3,
          amp: 2
      end
    end
  end
end


# pad_function
# ------------
define :pad do |dur, noot|
  strum = rrand(0, 0.05) # delay between chord notes
  l = noot.length
  
  noot.each do |n|
    with_fx :reverb, mix: 0.4 do
      attack_value = rrand(0.5, 0.75) * dur
      release_value = dur - attack_value
      play n, pan: rrand(-0.9, -0.2),
        attack: attack_value, release: release_value,
        cutoff: rrand(40, 90), amp: 1
      # doubled and detuned
      play n+0.05, pan: rrand(0.2, 0.9),
        attack: attack_value+0.2, release: release_value-0.2,
        cutoff: rrand(40, 90), amp: 1
    end
    sleep strum
  end
  sleep dur
end


# fm_stab_function
# ----------------
define :fm_stab do |n|
  n = n - 2
  with_fx :reverb, mix: 0.8, room: 1 do
    with_fx :echo, mix: 0.7, phase: 0.6  do
      with_fx :flanger do
        use_synth :fm
        play n, attack: 0, release: 0.15, amp: 1, cutoff: rrand(50, 120),
          amp: 1, divisor: 2, depth: rrand(1, 5)
      end
    end
  end
end


# geiger_function
# ---------------
define :geiger do |samp, sleeparray|
  # sleeparray is something like this: [0.125, 0.25, 0.33, 0.5, 0.66]
  with_fx :level, amp: 0.03 do
    with_fx :echo do |r|
      control r, mix: rrand(0.5, 1), phase: sleeparray.choose
      
      sample samp, finish: 0.01, amp: 0.5
      sleep sleeparray.choose
      with_fx :echo do |r2|
        control r2, mix: rrand(0.5, 1), phase: sleeparray.choose
        
        sample samp, finish: 0.01, amp: 0.5
      end
    end
  end
end


# one_shot_function
# -----------------
define :shot do |samp, rate, amp, reverbbottom|
  with_fx :reverb do |r|
    control r, mix: rrand(reverbbottom, 1), room: rrand(reverbbottom, 1), damp: 0.1
    sample samp, rate: rate, amp: amp, pan: rrand(-0.8, 0.8)
  end
  sleep 4
end


# random_global_sleep_function
climax_start = 32 # where all parts play fast
climax_length = 8

define :global_sleep do
  if ($measure < climax_start) || ($measure > (climax_start + climax_length))
    sleep rrand(0, 3) * 4
  end
end


# stop_after_measure_function
define :stop_after_measure do |m|
  if $measure > m
    stop
  end
end



# =================
# Music starts here
# =================
use_bpm 60
use_debug false

set_mixer_control! amp: 2  # default 1


# counting_measures
$measure = 0
in_thread do
  loop do
    stop_after_measure 71
    #cue :master
    $measure += 1
    puts "measure = #{$measure}"
    sleep 4
  end
end


# kick
in_thread do
  loop do
    stop_after_measure 65
    global_sleep
    sample :bd_boom
    sleep 4
  end
end


# bass_drone
in_thread do
  use_synth :tri
  loop do
    stop_after_measure 65
    global_sleep
    
    bsdrone :E1
    sleep 4
  end
end


# fm_stab
in_thread do
  loop do
    stop_after_measure 65
    
    sleep 1 * 4
    fm_stab [:e2, :g2].choose
    sleep 3 * 4
  end
end


# hihat_geiger
in_thread do
  loop do
    stop_after_measure 64
    
    if ($measure < climax_start) || ($measure > (climax_start + climax_length))
      geiger :elec_cymbal, [0.125, 0.25, 0.33, 0.5, 0.66]
      sleep rrand_i(1, 3)
    else
      geiger :elec_cymbal, [0.5, 0.66]
      sleep 1
    end
  end
end


# elec_snare_trumpet
in_thread do
  loop do
    stop_after_measure 63
    
    global_sleep
    human = rrand(0.01, 0.1)
    sleep 1*4
    
    sleep 2+human
    with_fx :pan, pan: rrand(-0.8, 0.8) do
      
      with_fx :reverb do |r|
        control r, mix: rrand(0.6, 1), room: rrand(0.6, 1), damp: 0.1
        sample :elec_lo_snare, rate: rrand(0.25, 0.5), amp: rrand(0.15, 0.4)
        
      end
      sleep 2-human
    end
  end
end


# dragon_fire
in_thread do
  loop do
    stop_after_measure 65
    
    sleep 5
    with_fx :pan, pan: rrand(0.2, 0.8) do
      with_fx :reverb do |r|
        control r, mix: rrand(0.6, 0.7), room: rrand(0.6, 1), damp: 0.1
        sample :elec_fuzz_tom, rate: rrand(0.02, 0.05), amp: rrand(1, 1.5)
      end
    end
    sleep 4
  end
end

# low_drum_hit
in_thread do
  loop do
    stop_after_measure 64
    global_sleep
    
    sleep 1*4
    sleep 3.75
    
    with_fx :reverb do |r|
      control r, mix: rrand(0.7, 0.9), room: 1, damp: 0.1
      sample :elec_pop, rate: 0.20, amp: 0.25, pan: rrand(-0.8, 0.8)
    end
    sleep 0.25
  end
end

# bowed_synth
in_thread do
  use_synth :tri
  loop do
    stop_after_measure 66
    global_sleep
    human = rrand(0.1, 1)
    
    with_fx :level, amp: rrand(0.07, 0.08) do
      with_fx :reverb do |r5|
        control r5, mix: rrand(0.7, 0.9), room: rrand(0.95, 1), damp: 0.1
        sleep 2+human
        
        with_fx :lpf, cutoff: rrand(90, 130) do
          with_fx :tanh do
            
            play :E3,
              attack: rrand(0.9, 1.4), release: 1
            sleep 0.5
            
            play :e4,
              attack: rrand(0.75, 1), release: 0.5
            sleep 0.5
            
            play [:d5, :e5, :B5].choose,
              attack: rrand(0.5, 1), release: 0.25,
              cutoff: rrand(40, 90)
            sleep 1-human
          end
        end
      end
    end
    sleep 4
  end
end


sleep 20*4

use_random_seed 21500

# pad
in_thread do
  use_synth :hollow
  loop do
    stop_after_measure 53
    with_fx :reverb, mix: 0.8 do
      
      choice = rrand_i(1, 6)
      case choice
      when 1; pad 6, [:E4, :A4, :B4, [:E5, :r].choose]
      when 2; pad 6, [:G4, :C5, :D5, [:E5, :r].choose]
      when 3; pad 6, [:D4, :Fs4, :A4, :E5]
      when 4; pad 6, [:A4, :Cs5, :E5, :B5]
      when 5; pad 6, [:C4, :E4, :G4, :D5]
      when 6; pad 6, [:Fs4, :A4, :Cs5, :E5]
      end
    end
  end
end



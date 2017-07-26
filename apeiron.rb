# Apeiron
# *******
# Coded by Ard Vank with Sonic Pi v2.10

use_bpm 30
use_debug false


# Index
# -----
# FUNCTIONS
#
# helper functions
# - define :midi_to_note do |m|
# - define :no_dissonance do |low_note, hi_note|
#
# bass_sound
# mid_and_hi_sound

# play_bass_function
# play_mid_and_hi_function

# Music starts here
# -----------------
# note_arrays
# counting and syncing measures
# choose global parameters for every bar
# bass_part
# mid_part
# hi_part



# FUNCTIONS
# ---------
# convert a midi number to a note symbol
define :midi_to_note do |m|
  octave = (m / 12) - 1
  i = (m - ((m/12) * 12))
  notestring = "C CsD DsE F FsG GsA AsB "[(i*2)..(i*2)+1]
  returnstring = notestring.strip + octave.to_s
  return returnstring.to_sym
end


# compare two notes for dissonance; make the second note
# one note higher if it's dissonant with the first one
define :no_dissonance do |low_note, hi_note|
  l = note(low_note, octave: 4)
  h = note(hi_note, octave: 4)

  hi_midi_nr = note(hi_note)

  if h == note(:c, octave: 4)
    h = note(:c, octave: 5)
  end
  if (h - l) == 1
    hi_midi_nr += 1
    # returnnoot = hi_note + 1
  end
  return midi_to_note hi_midi_nr
end


# bass_sound
define :bs do |n, dur|
  with_fx :lpf, cutoff: 60 do
    use_synth :tri
    attack_value = rrand(dur * 0.25, dur * 0.5)
    release_value = (dur - attack_value)
    play n, pan: rrand(-0.5, -0.2),
      attack: attack_value, release: release_value,
      amp: 1.1
    # doubled and detuned
    play n+0.1, pan: rrand(0.2, 0.9),
      attack: attack_value, release: release_value,
      amp: 1.1
    use_synth :blade
    play n, pan: rrand(-0.5, -0.2),
      attack: attack_value, release: release_value,
      amp: 0.7,
      vibrato_rate:  $v_rate,
      vibrato_depth: $v_depth,
      vibrato_delay: $v_delay,
      vibrato_onset: $v_onset
    puts "bass note: #{n}"
  end
end


# mid_and_hi_sound
define :hi do |n, dur|
  with_fx :lpf, cutoff: 90  do
    use_synth :blade
    attack_value = rrand(dur * 0.25, dur * 0.5)
    release_value = (dur - attack_value)

    play n, pan: rrand(-0.9, -0.2),
      attack: attack_value, release: release_value,
      cutoff: rrand(50, 70), amp: 1,
      vibrato_rate:  $v_rate,
      vibrato_depth: $v_depth,
      vibrato_delay: $v_delay,
      vibrato_onset: $v_onset

    # doubled and detuned
    play n+12.15, pan: rrand(0.2, 0.9),
      attack: attack_value, release: release_value,
      cutoff: rrand(60, 70), amp: 1

    puts "mid/hi note: #{n}"

  end
end


# play_bass_function
define :play_bass do |n, dur|
  c = rrand_i(1,8)
  case c
  when 1
    bs n, dur
    sleep dur
  when 2
    bs n, dur
    sleep dur
  when 3
    sleep0 = [0.125, 0.25, 0.5, 0.75].choose
    sleep1 = dur * sleep0
    sleep2 = dur - sleep1
    bs n, sleep1
    sleep sleep1
    bs n, sleep2
    sleep sleep2
  else
    sleep dur * 0.5
    bs n, (dur * 0.5)
    sleep dur * 0.5
  end
end


# play_mid_and_hi_function
define :play_hi do |n, dur|
  c = rrand_i(1,8)
  case c
  when 1
    hi n, dur
    sleep dur
  when 2
    hi n, dur
    sleep dur
  when 3
    sleep0 = [0.125, 0.25, 0.5, 0.75].choose
    sleep1 = dur * sleep0
    sleep2 = dur - sleep1
    hi n, sleep1
    sleep sleep1
    hi n, sleep2
    sleep sleep2
  else
    sleep dur * 0.5
    hi n, (dur * 0.5)
    sleep dur * 0.5
  end
end



# =================
# Music starts here
# =================
# use_random_seed 2150

#bass_notes = [:A2, :E2, :G2, :A2, :A2]
#mid_notes = [:C3, :E3, :G3, :A3, :B3]
#hi_notes = [:C3, :D3, :E3, :F3, :G3, :A3, :B3, :C4, :D4, :E4]


# note_arrays
bass_notes = [:A2, :E2, :G2, :A2, :D2, :A2]
mid_notes = [:C3, :D3, :E3, :F3, :G3, :A3, :B3]
hi_notes = [:C4, :D4, :E4, :F4, :G4, :A4, :B4, :C5, :D5, :E5]


# counting and syncing measures
$measure = 0
in_thread do
  loop do
    cue :master
    $measure += 1
    puts "measure = #{$measure}"
    sleep 4
  end
end


# choose global parameters for every bar
in_thread do
  loop do
    # notes
    $bass = bass_notes.choose
    midoption = mid_notes.choose
    $mid = no_dissonance $bass, midoption

    hi = hi_notes.choose
    hib = no_dissonance $bass, hi
    $hi1 = no_dissonance $mid, hib

    hi = hi_notes.choose
    hib = no_dissonance $bass, hi
    $hi2 = no_dissonance $mid, hib

    hi = hi_notes.choose
    hib = no_dissonance $bass, hi
    $hi3 = no_dissonance $mid, hib

    # ibrato parameters
    $v_rate = rrand(5, 7)
    $v_depth = rrand(0.1, 0.15)
    $v_delay = rrand(0.4, 0.8)
    $v_onset = rrand(0.01, 0.1)

    sleep 4
  end
end


# FIXME resonances on certain note combinations
with_fx :gverb, mix: 0.6, pre_amp: 1,  room: 10,  
  release: 3, ref_level: 0.7, tail_level: 0.4 do 

  # bass_part
  in_thread do
    loop do
      play_bass $bass, 4
    end
  end


  # mid_part
  in_thread do
    loop do
      play_hi $mid, 2
      play_hi $mid, 2
    end
  end
 

  # hi_part
  in_thread do
    loop do
      play_hi [$hi1, $hi2, $hi3].choose, 2
      play_hi [$hi1, $hi2, $hi3].choose, 2
    end
  end
end




require 'yaml'

class MetroInfopoint
  attr_accessor :timing, :stations

  def initialize(path_to_timing_file: '', path_to_lines_file: '')
    @info = YAML.load_file('config/config.yml')
    @timing = YAML.load_file('config/timing2.yml')['timing']
    @stations = @info['stations']
  end

  def calculate(from_station:, to_station:)
    { price: calculate_price(from_station: from_station, to_station: to_station),
      time: calculate_time(from_station: from_station, to_station: to_station) }
  end

  def calculate_price(from_station:, to_station:)
    calculated('price', from_station, to_station)
  end

  def calculate_time(from_station:, to_station:)
    calculated('time', from_station, to_station)
  end

  def calculated(data, from_station, to_station)
    route = get_hash(from_station, to_station)
    s_count = route.count
    i = 0
    total = 0

    while i+1 < s_count
      info = timing.select { |t| t['start'].to_s == route[i] && t['end'].to_s == route[i+1] }[0]
      total += info[data]
      i += 1
    end

    total
  end

  def get_hash(from_station, to_station)
    first_station = stations.find { |s| s if s[0] == to_station || s[0] == from_station }[0]

    if first_station == from_station
      last_station = to_station
    else
      last_station = from_station
    end

    from_line = stations[first_station][0]
    to_line = stations[last_station][0]
    result = 0
    reserve_station = ''
    intermediate_station = ''
    array = []

    while first_station != last_station do
      if array.include? (first_station)
        array.slice!(-1) while array.last != intermediate_station
        first_station = reserve_station
      end

      array.push(first_station)

      if (from_line != to_line) && (stations[first_station].count > 1)
        info = timing.select { |t| t['start'].to_s == first_station }
        from_line = stations[first_station][1]
        intermediate_station = first_station
        info.find { |i| first_station = i['end'].to_s if stations[i['end'].to_s] == [from_line] }
        info.select { |i| reserve_station = i['end'].to_s if stations[i['end'].to_s] == [from_line] }
      else
        info = timing.find { |t| t['start'].to_s == first_station }
        first_station = info['end'].to_s
      end
    end

    array.push(last_station)
  end
end

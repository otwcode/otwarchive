# based on http://snippets.dzone.com/posts/show/2631
class String
  def chunk_string(average_segment_size = 300000, slice_on = /<hr/i)
    out = []
    slices_estimate = self.size.divmod(average_segment_size)
    slice_count = (slices_estimate[1] > 0 ? slices_estimate[0] + 1 : slices_estimate[0])
    slice_guess = self.size / slice_count
    previous_slice_location = 0
    (1..slice_count - 1).each do |i|
      slice_location = self.nearest_split(slice_guess * i, slice_on)
      out << self.slice(previous_slice_location..slice_location)
      previous_slice_location = slice_location + 1
    end
    out << self.slice(previous_slice_location..self.size)
    out
  end

  def nearest_split(slice_start, slice_on)
    left_scan_location  = (self.slice(0..slice_start).rindex(slice_on)).to_i - 1
    right_scan_location = (self.slice((slice_start+1)..self.size).index(slice_on)).to_i + slice_start
    ((slice_start - left_scan_location) < (right_scan_location - slice_start) ? left_scan_location : right_scan_location)
  end
end

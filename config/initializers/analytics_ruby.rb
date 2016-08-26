Analytics = Segment::Analytics.new({
                                       write_key: 'omxSEzRK0cHFvA0nPC6lNBEtScyeoapT',
                                       on_error: Proc.new { |status, msg| print msg }
                                   })
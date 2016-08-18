Analytics = Segment::Analytics.new({
                                       write_key: '90PWvCwVDahUXMa1Tmu4tK2TA1yE7JV4',
                                       on_error: Proc.new { |status, msg| print msg }
                                   })
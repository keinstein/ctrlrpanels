a = { x = 1,
      y = 2,
      z = 3,
      h = function (x)
	 print "h"
	 print (x)
      end
}
a.g = function(x)
   print "ok"
   print (x)
end

a.g()
a:g()

a.h()
a:h()

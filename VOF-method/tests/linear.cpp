#define BOOST_TEST_MODULE geometry_toolbox
#include <boost/test/included/unit_test.hpp>

#include "../PLIC.h"
#include "../structures.h"
#include "../linear.h"

BOOST_AUTO_TEST_CASE(linear_solver)
{
  const line_segment l1 = {{2, 2}, 9.0};
  const point p1 = {2.5, 2.0};

  BOOST_TEST(compute_y(l1, p1.x) == p1.y);
  BOOST_TEST(compute_x(l1, p1.y) == p1.x);
}

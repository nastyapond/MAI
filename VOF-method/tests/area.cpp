#define BOOST_TEST_MODULE geometry_toolbox
#include <boost/test/included/unit_test.hpp>

#include "../PLIC.h"
#include "../structures.h"

BOOST_AUTO_TEST_CASE(polygon_area)
{
  const point point1 = {0,0};
  const point point2 = {1,0};
  const point point3 = {1,1};
  const point point4 = {0,1};

  const std::vector<point> points1 = {point1, point2, point3, point4};
  const std::vector<point> points2 = {point1, point2, point3};

  const polygon square(points1);
  const double square_area = PLIC::polygon_area (square);
  BOOST_TEST(square_area == 1.);

  const polygon triangle(points2);
  const double triangle_area = PLIC::polygon_area (triangle);
  BOOST_TEST(triangle_area == 0.5);
}


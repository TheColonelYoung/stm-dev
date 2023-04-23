#include <catch2/catch_test_macros.hpp>
//#include <fakeit.hpp>

#include "sensor.hpp"

TEST_CASE("ID_test", "[ID_test]" ) {
    auto sensor = Sensor();
    REQUIRE(sensor.ID() == 42);
    REQUIRE(sensor.ID() == 0x82);
}

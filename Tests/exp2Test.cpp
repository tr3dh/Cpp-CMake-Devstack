#include <gtest/gtest.h>

TEST(DefaultTest, Addition) {
    EXPECT_EQ(2 + 2, 4);
    EXPECT_NE(2 + 2, 5);
}

TEST(DefaultTest, StringVergleich) {
    std::string s = "hallo";
    EXPECT_EQ(s, "hallo");
    EXPECT_FALSE(s.empty());
}
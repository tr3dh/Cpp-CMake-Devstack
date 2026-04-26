#include <type_traits>

template<typename E>
struct enable_bitmask_operators : std::false_type {};

template<typename E>
constexpr std::enable_if_t<enable_bitmask_operators<E>::value, E>
operator|(E a, E b)
{
    using U = std::underlying_type_t<E>;
    return static_cast<E>(static_cast<U>(a) | static_cast<U>(b));
}

template<typename E>
constexpr std::enable_if_t<enable_bitmask_operators<E>::value, E>
operator&(E a, E b)
{
    using U = std::underlying_type_t<E>;
    return static_cast<E>(static_cast<U>(a) & static_cast<U>(b));
}

template<typename E>
constexpr std::enable_if_t<enable_bitmask_operators<E>::value, E&>
operator|=(E& a, E b)
{
    return a = a | b;
}

template<typename E>
constexpr bool hasFlag(E value, E flag)
{
    using U = std::underlying_type_t<E>;
    return (static_cast<U>(value) & static_cast<U>(flag)) != 0;
}

#define ENABLE_BITMASK(E) \
template<> struct enable_bitmask_operators<E> : std::true_type {}

// Beispielhafte Nutzung
//
// enum class WindowFlags : std::uint32_t
// {
//     None = 0,
//     NoTitleBar = 1 << 0,
//     NoResize   = 1 << 1,
//     NoMove     = 1 << 2,
//     NoScrollbar= 1 << 3
// };
//
// ENABLE_BITMASK(WindowFlags);
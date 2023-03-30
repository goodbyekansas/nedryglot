#pragma once
#include <cstdint>
#include <string>

/**
 * @file up.h
 * Non-trivial up casing functions.
 *
 */

/**
 * Non-trivial up casing functions.
 */
namespace up {

/**
 * Convert a utf-8 string to uppercase.
 *
 * @returns a utf-8 buffer with the string in uppercase.
 */
uint8_t *upcase(const std::string &input);

} // namespace up

# README

## Introduction

The challenge requires you to somehow mint yourself at least 10 Meal NFTs.

## Solution

The vulnerability is that the return value of `ecrecover()` is never checked against if it's zero.

`ecrecover()` returns 0x0 address on invalid parameters, and that's the same as `oracle`, as is never set.

This allows us to set fake prices (0 in my script), and buy as many Meal NFTs as needed for free.
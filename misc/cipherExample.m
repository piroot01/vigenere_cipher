% Testing script for competition task MTB Summer Semester 22/23 titled
% "Can you crack Vignere cipher?"
% 
% see https://cw.fel.cvut.cz/wiki/courses/mtb/projects/competition 

clc; clear; close all;

% Plain text for testing purposes, Chorus from Romeo and Juliet
plaintext = fileread('romeoChorus.txt');

% plaintext is ciphered with key = 'IL()VESTR!NGS'; 
% obtaining ciphertext:
ciphertext = fileread('romeoChorusCiphered.txt');

% The much longer text will be considered for performance measuring, 
% so develop also your data for testing purposes!

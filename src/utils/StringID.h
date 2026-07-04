/**
 * @file    StringID.h
 * @brief   Declaration of StringID class and related utilities
 * @author  Tim Rother
 * @copyright (c) 2026 Tim Rother – MIT License
 */
#pragma once

#include <iostream>
#include <assert.h>
#include <unordered_map>
#include <functional>

/// @brief Typ der eine Identifikationsnummer repräsentiert
typedef uint16_t ID;

/// @brief Default String
extern std::string nullstring;

/// @brief Namespace der intern Stringregistrierung mit ID-Vergabe regelt
namespace StringRegistry{

    /// @brief Counter, der genutzt wird, um Strings bei Registrierung eine eindeutige ID zuzuweisen
    extern ID IDCounter;

    /// @brief Register in dem die zugewiesenen IDs unter dem entsprechenden, registrierten String abgespeichert werden
    extern std::unordered_map<std::string, ID> StringToIDAssignment;
    extern std::unordered_map<ID, std::string> IDToStringAssignment;

    /// @brief Funktion, die den übergebenen String registriert und eine ID zurückgibt  
    ///        oder, falls der String bereits registriert ist, die bereits vergebene ID
    /// @param str Zeichenkette, die registriert werden soll
    /// @return ID des Strings
    ID getID(const std::string& str);

    /// @brief Funktion die Referenz auf für ID hinterlegten String zurückgibt
    /// @param id ID für die String Referenz zurückgegeben werden soll
    /// @return String Referenz
    std::string& getString(const ID& id);
};

/// @brief Datentyp der Registrierungs-ID eines Strings packt
struct StringID{

    /// @brief Enthält die ID des repräsentierten Strings
    ID m_ID = -1;

    /// @brief Funktion, die übergebenen String registriert wenn nicht im Register vorhanden und Registrierungs-ID im
    ///        StringID-Objekt hinterlegt
    /// @param str Zeichenkette, deren Registrierungs-ID hinterlegt werden soll
    /// @return Eigenreferenz
    StringID& operator=(const std::string& str);

    /// @brief Funktion, die übergebenen Char Pointer registriert wenn nicht im Register vorhanden und Registrierungs-ID im
    ///        StringID-Objekt hinterlegt
    /// @param cstr Char Pointer, dessen Registrierungs-ID hinterlegt werden soll
    /// @return Eigenreferenz
    StringID& operator=(const char* cstr);

    /// @brief StringID Standardkonstruktor
    StringID();

    /// @brief StringID Konstruktor
    /// @param str String dessen Registrierungs-ID hinterlegt werden soll
    StringID(const std::string& str);

    /// @brief StringID Konstruktor
    /// @param cstr Char Pointer, dessen Registrierungs-ID hinterlegt werden soll
    StringID(const char* cstr);

    /// @brief Abgleich von zwei StringID-Objekten über '==' Operator
    /// @param other zweiter StringID Abgleichs-Operand
    /// @return Boolscher Wert der Gleichheit der Operanden angibt
    bool operator==(const StringID& other) const noexcept;

    /// @brief Funktion, die StringID-Handhabung durch den Operator '<' automatisch definiert
    /// @param other Anderer StringID Member, mit dem verglichen wird
    /// @return Abgleich Ergebnis der StringID Operanden über Operator '<'
    std::strong_ordering operator<=>(const StringID&) const;

    /// @brief Funktion die Referenz auf String hinter hinterlegter Registrierungs-ID zurückgibt
    /// @return Referenz auf String hinter hinterlegter Registrierungs-ID zurückgibt
    std::string* operator*() const;

    /// @brief Funktion die Referenz auf String hinter hinterlegter Registrierungs-ID zurückgibt
    /// @return Referenz auf String hinter hinterlegter Registrierungs-ID zurückgibt
    std::string* operator->() const;
};

/// @brief Überladung des '<<' Operators für den Printout von StringID-Objekten
/// @param os Ostream, in den Printout geschoben werden soll
/// @param strID auszugebenes StringID-Objekt
/// @return Referenz auf übergebenen ostream
std::ostream& operator<<(std::ostream& os, const StringID& strID);

/// @brief Ergänzung von hash Infos
namespace std {

    /// @brief Wrapper für hash Angabe
    template<>
    struct hash<StringID> {

        /// @brief Deklaration von Funktion die bei Hash aufgerufen wird 
        /// @param strID Input StringID
        /// @return Rückgabe der ID über Cast
        size_t operator()(const StringID& strID) const noexcept {
            return static_cast<size_t>(strID.m_ID);
        }
    };
}
# spq() works

    Code
      spq("DESC(?length) ?item_label")
    Output
      <SPARQL> DESC(?length) ?item_label

---

    Code
      spq(1)
    Condition
      Error in `c_character()`:
      ! Character input expected


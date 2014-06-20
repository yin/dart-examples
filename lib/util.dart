/**
 * Experimental class used to write condensed for..in loops
 */
class For {
  final dynamic value;
  final Symbol flow;
  String label = null;
  For.Return(dynamic value) :
    value = value,
    flow = null {
  }
  For.Break() :
    value = null,
    flow = #Break {
  }
  For.Continue() :
    value = null,
    flow = #Continue {
  }
  For Label(String label) {
    this.label = label;
    return this;
  }
  dynamic get Do => throw this;

  /**
   * Iterates over an Interable/List and calls callback for each element.
   * If callback throws a value, it is returned from _for().
   * Throw #_continue to invoke keyword continue in the loop.
   * Throw #_break to invoke break.
   */
  static dynamic each(Iterable iterable, void callback(dynamic), {label : null}) {
    for (var element in iterable) {
        try {
          callback(element);
        } catch(ret) {
          if (ret is For) {
            if (ret.label == label) {
              if(ret.flow == #Continue) {
                continue;
              } else if (ret.flow == #Break) {
                break;
              }
            } else {
              throw ret;
            }
          } else {
            return ret;
          }
        }
      }
    return null;
  }
}

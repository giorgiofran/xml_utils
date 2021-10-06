import 'package:xml/xml.dart';

const keyName = 'name';

const attributeName = 'name';
const attributeType = 'type';
const attributeUse = 'use';

const attributeBase = 'base';
const attributeLength = 'length';
const attributeMinLength = 'minLength';
const attributeValue = 'value';
const attributeMaxLength = 'maxLength';
const attributeMinOccurs = 'minOccurs';
const attributeMaxOccurs = 'maxOccurs';
const attributeDefault = 'default';
const attributeRef = 'ref';

/// Given a certain list of attributes (attributeList is in the format
/// {attributeName (with namespace) : mandatory (true|false)}) the method return a map
/// in format {attributeName: value}
/// The return map does not contain the optional attributes if not present
/// The default namespace is with separator (Ex "xs:")
Map<String, String> extractAttributes(XmlElement element,
    Map<String, bool> attributesList, String defaultNamespace) {
  var ret = <String, String>{};
  var attributes = element.attributes;
  for (var attribute in attributes) {
    if (attribute.name.prefix == 'xmlns' ||
        attribute.name.qualified == 'xmlns' ||
        attribute.name.prefix == 'xsi') {
      continue;
    }
    if (attributesList.containsKey(attribute.name.local)) {
      ret[attribute.name.local] = attribute.value;
    } else if (attributesList.containsKey(attribute.name.qualified)) {
      ret[attribute.name.qualified] = attribute.value;
    } else if (attributesList
        .containsKey('$defaultNamespace${attribute.name.local}')) {
      ret['$defaultNamespace${attribute.name.local}'] = attribute.value;
    } else {
      throw StateError('Unexpected attribute "${attribute.name.qualified}"');
    }
  }
  // Check if mandatory attributes are present
  for (var requiredAttribute in attributesList.keys) {
    if (attributesList[requiredAttribute] ?? true) {
      if (!ret.containsKey(requiredAttribute)) {
        throw StateError('The required attribute "$attributeName" is missing');
      }
    }
  }
  return ret;
}

/// returns a map with pairs element name -> XmlElement | List<XmlElement>
Map<String, dynamic> extractChildren(XmlElement parent) {
  var ret = <String, dynamic>{};
  for (var node in parent.children) {
    if (node is! XmlElement) {
      continue;
    }

    if (ret.containsKey((node).name.local)) {
      var oldNode = ret[(node).name.local];
      if (oldNode == null) {
        throw StateError('Something wrong happened');
      }
      if (oldNode is List) {
        oldNode.add(node);
      } else {
        ret[(node).name.local] = [oldNode, node];
      }
      continue;
    }
    ret[(node).name.local] = node;
  }

  return ret;
}

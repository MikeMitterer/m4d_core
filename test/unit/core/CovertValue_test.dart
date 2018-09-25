// @TestOn("browser")
// unit
library test.unit.covertvalue;

import 'package:test/test.dart';
import 'package:m4d_core/m4d_utils.dart';

// import 'package:logging/logging.dart';


main() async {
    // final Logger _logger = new Logger("test.unit.covertvalue");

    group('CovertValue', () {
        setUp(() {});

        test('> toBool', () {
            expect(ConvertValue.toBool(true), isTrue);
            expect(ConvertValue.toBool(1), isTrue);
            expect(ConvertValue.toBool("1"), isTrue);
            expect(ConvertValue.toBool("yes"), isTrue);
            expect(ConvertValue.toBool("true"), isTrue);
            expect(ConvertValue.toBool("True"), isTrue);

            expect(ConvertValue.toBool(false), isFalse);
            expect(ConvertValue.toBool(2), isFalse);
            expect(ConvertValue.toBool("0"), isFalse);
            expect(ConvertValue.toBool("No"), isFalse);
            expect(ConvertValue.toBool("false"), isFalse);
            expect(ConvertValue.toBool("FALSE"), isFalse);

        }); // end of 'toBool' test

        test('> toInt', () {
            expect(ConvertValue.toInt(1), equals(1));
            expect(ConvertValue.toInt("1"), equals(1));
            expect(ConvertValue.toInt("2.99"), equals(2));
            expect(ConvertValue.toInt("2.01"), equals(2));
            expect(ConvertValue.toInt(2.99), equals(2));
        }); // end of 'toInt' test

        test('> toDouble', () {
            expect(ConvertValue.toDouble("1"), equals(1.0));
            expect(ConvertValue.toDouble(1), equals(1.0));
            expect(ConvertValue.toDouble(2.99), equals(2.99));

            expect(() => ConvertValue.toDouble("abc"), throwsFormatException);
        }); // end of 'toDouble' test

    });
    // End of 'CovertValue' group
}

// - Helper --------------------------------------------------------------------------------------

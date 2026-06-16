import '../entities/domain.dart';
import '../entities/domain_link.dart';

abstract class DomainRepositoryInterface {
  Future<List<Domain>> getAll();
  Future<Domain?> getById(int id);
  Future<List<DomainAttributeLink>> findAttributesForDomain(int domainId);
  Future<List<DomainEmotionLink>> findEmotionsForDomain(int domainId);
}

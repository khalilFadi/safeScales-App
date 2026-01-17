// --- Dragon Dress Up Page ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_scales/providers/dragon_decoration_provider.dart';
import 'package:safe_scales/ui/widgets/dragon_image_widget.dart';
import 'package:safe_scales/ui/widgets/sticker_collection_widget.dart';
import 'package:safe_scales/models/sticker_item_model.dart';
import '../../../providers/dragon_provider.dart';

class DragonDressUpPage extends StatefulWidget {
  final String dragonId;
  final String currentPhase;

  const DragonDressUpPage({
    super.key,
    required this.dragonId,
    required this.currentPhase,
  });

  @override
  _DragonDressUpPageState createState() => _DragonDressUpPageState();
}

class _DragonDressUpPageState extends State<DragonDressUpPage> {
  String selectedPhase = '';

  @override
  void initState() {
    super.initState();
    selectedPhase = widget.currentPhase;

    // Use addPostFrameCallback to ensure initialization happens after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final dragonDecorationProvider = Provider.of<DragonDecorationProvider>(
      context,
      listen: false,
    );

    try {
      // Initialize the decoration provider if not already done
      if (!dragonDecorationProvider.isInitialized) {
        await dragonDecorationProvider.initialize(widget.dragonId);
      }

      await _loadCurrentPhase();
    } catch (e) {
      debugPrint('Initialization error: $e');
    }
  }

  Future<void> _loadCurrentPhase() async {
    final dragonProvider = Provider.of<DragonProvider>(context, listen: false);
    await dragonProvider.initialize();

    final phase = await dragonProvider.getUserPreferredPhase(widget.dragonId);

    try {
      final availablePhases =
          dragonProvider.unlockedDragonPhases[widget.dragonId];
      if (availablePhases != null && availablePhases.contains(phase)) {
        setState(() => selectedPhase = phase);
      }
    } catch (e) {
      debugPrint('Error loading current phase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double dragonSize = screenWidth * 0.75;

    // Ensure environment size doesn't exceed screen bounds
    final environmentWidth = (dragonSize * 1.25).clamp(0.0, screenWidth * 0.95);
    final environmentHeight = (dragonSize * 1.8).clamp(0.0, screenHeight * 0.6);
    
    final environmentSize = (
      width: environmentWidth,
      height: environmentHeight,
    );

    final stickerEnvironmentSize = (
      width: environmentSize.width - 10,
      height: environmentSize.height - 10,
    );

    return Consumer2<DragonDecorationProvider, DragonProvider>(
      builder: (context, dragonDecorationProvider, dragonProvider, child) {
        // Show loading indicator if still initializing
        if (dragonDecorationProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Play'),
              centerTitle: true,
              backgroundColor: colorScheme.surface,
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Show error if there's an error
        if (dragonDecorationProvider.error != null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Play'),
              centerTitle: true,
              backgroundColor: colorScheme.surface,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: colorScheme.error),
                  SizedBox(height: 16),
                  Text(
                    'Error: ${dragonDecorationProvider.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.error),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => dragonDecorationProvider.refresh(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onTap: () => _showNameDialog(dragonProvider),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      dragonProvider.getDragonById(widget.dragonId)?.name ??
                          'Unnamed Dragon',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Icon(Icons.edit, size: 25),
                ],
              ),
            ),
            centerTitle: true,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 35),
                onSelected: (value) {
                  if (value == 'clear') _clearAllStickers();
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'clear',
                        child: Text('Clear All Items'),
                      ),
                    ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Hint info
              Container(
                // padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'Tap an item to move and resize it',
                      style: theme.textTheme.labelSmall,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Use buttons to resize or change layer',
                      style: theme.textTheme.labelSmall,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Long press an item to remove it',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              
              // Prominent selection buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showPhaseDialog(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pets,
                                size: 20,
                                color: colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Dragon Phase',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showEnvironmentDialog(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: dragonDecorationProvider.getCurrentEnvironment() != null
                                ? colorScheme.primaryContainer
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: dragonDecorationProvider.getCurrentEnvironment() != null
                                  ? colorScheme.primary.withValues(alpha: 0.3)
                                  : colorScheme.outline.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.landscape,
                                size: 20,
                                color: dragonDecorationProvider.getCurrentEnvironment() != null
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  _getEnvironmentDisplayName(dragonDecorationProvider),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: dragonDecorationProvider.getCurrentEnvironment() != null
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Dragon area with drop zone
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Environment background
                      if (dragonDecorationProvider.getCurrentEnvironment() !=
                          null)
                        Container(
                          width: environmentSize.width,
                          height: environmentSize.height,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            image: DecorationImage(
                              image: NetworkImage(
                                dragonDecorationProvider
                                    .getCurrentEnvironment()!
                                    .imageUrl,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                      // Stickers behind the dragon
                      ...dragonDecorationProvider.placedStickers
                          .where((sticker) => sticker.isBehindDragon)
                          .map((sticker) {
                            final isSelected =
                                dragonDecorationProvider
                                    .selectedStickerId ==
                                sticker.id;

                            return _buildSticker(
                              sticker,
                              isSelected,
                              stickerEnvironmentSize,
                              dragonDecorationProvider,
                            );
                          }),

                      // Drop zone for dragon
                      DragTarget<Map<String, dynamic>>(
                        builder: (context, candidateData, rejectedData) {
                          return GestureDetector(
                            onTap: () {
                              // Deselect any currently selected sticker when tapping background
                              dragonDecorationProvider.selectSticker(null);
                            },
                            child: Container(
                              width: environmentSize.width,
                              height: environmentSize.height,
                              decoration: BoxDecoration(
                                color:
                                    candidateData.isNotEmpty
                                        ? colorScheme.primary.withValues(
                                          alpha: 0.1,
                                        )
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      candidateData.isNotEmpty
                                          ? colorScheme.primary
                                          : colorScheme.primary.withValues(
                                            alpha: 0.2,
                                          ),
                                  width: candidateData.isNotEmpty ? 3 : 2,
                                ),
                              ),
                            ),
                          );
                        },
                        onAcceptWithDetails: (details) {
                          _handleStickerDrop(
                            details,
                            dragonSize,
                            environmentSize,
                            dragonDecorationProvider,
                          );
                        },
                      ),

                      // Dragon Image
                      DragonImageWidget(
                        dragonId: widget.dragonId,
                        size: dragonSize * 0.75,
                        phase: selectedPhase,
                      ),

                      // Stickers in front of the dragon
                      ...dragonDecorationProvider.placedStickers
                          .where((sticker) => !sticker.isBehindDragon)
                          .map((sticker) {
                            final isSelected =
                                dragonDecorationProvider
                                    .selectedStickerId ==
                                sticker.id;

                            return _buildSticker(
                              sticker,
                              isSelected,
                              stickerEnvironmentSize,
                              dragonDecorationProvider,
                            );
                          }),
                    ],
                  ),
                ),
              ),

              // Whitespace between dragon habitat and item collection
              const SizedBox(height: 24),

              // Accessory picker
              StickerCollectionWidget(
                isLoadingAccessories:
                    dragonDecorationProvider.isLoadingAccessories,
                userAccessories: dragonDecorationProvider.userItems,
              ),
            ],
          ),
          backgroundColor: colorScheme.surface,
        );
      },
    );
  }

  String _getEnvironmentDisplayName(DragonDecorationProvider provider) {
    if (provider.isLoadingEnvironments) {
      return 'Loading...';
    }

    if (provider.isNoEnvironmentSelected) {
      return 'None';
    }

    final currentEnv = provider.getCurrentEnvironment();
    return currentEnv?.name ?? 'None';
  }

  void _showPhaseDialog() async {
    final dragonProvider = Provider.of<DragonProvider>(context, listen: false);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final availablePhases =
        dragonProvider.unlockedDragonPhases[widget.dragonId];
    if (availablePhases == null) {
      return;
    }

    int? choice = await showDialog<int>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: colorScheme.surface,
        child: Container(
          constraints: BoxConstraints(maxWidth: 400, maxHeight: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.pets,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select Dragon Phase',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      availablePhases.length,
                      (i) {
                        final isSelected = availablePhases[i] == selectedPhase;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primaryContainer
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.pop(context, i),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: colorScheme.primary,
                                        size: 24,
                                      )
                                    else
                                      Icon(
                                        Icons.circle_outlined,
                                        color: colorScheme.onSurfaceVariant,
                                        size: 24,
                                      ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        dragonProvider.getPhaseDisplayName(
                                          availablePhases[i],
                                        ),
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          color: isSelected
                                              ? colorScheme.onPrimaryContainer
                                              : colorScheme.onSurface,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (choice != null && choice < availablePhases.length) {
      setState(() => selectedPhase = availablePhases[choice]);
      await dragonProvider.updateUserPreferredPhase(
        widget.dragonId,
        availablePhases[choice],
      );
    }
  }

  void _showEnvironmentDialog() async {
    final decorationProvider = Provider.of<DragonDecorationProvider>(
      context,
      listen: false,
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (decorationProvider.isLoadingEnvironments) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Loading habitats...')));
      return;
    }

    final currentEnv = decorationProvider.getCurrentEnvironment();
    final currentEnvId = currentEnv?.id ?? '';

    int? choice = await showDialog<int>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: colorScheme.surface,
        child: Container(
          constraints: BoxConstraints(maxWidth: 400, maxHeight: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.landscape,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select Habitat',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // None option
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: decorationProvider.isNoEnvironmentSelected
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: decorationProvider.isNoEnvironmentSelected
                                ? colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(context, -1),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  if (decorationProvider.isNoEnvironmentSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: colorScheme.primary,
                                      size: 24,
                                    )
                                  else
                                    Icon(
                                      Icons.circle_outlined,
                                      color: colorScheme.onSurfaceVariant,
                                      size: 24,
                                    ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'None',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: decorationProvider.isNoEnvironmentSelected
                                            ? colorScheme.onPrimaryContainer
                                            : colorScheme.onSurface,
                                        fontWeight: decorationProvider.isNoEnvironmentSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Environment options
                      ...List.generate(
                        decorationProvider.userEnvironments.length,
                        (i) {
                          final env = decorationProvider.userEnvironments[i];
                          final isSelected = env.id == currentEnvId;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primaryContainer
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? colorScheme.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.pop(context, i),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle,
                                          color: colorScheme.primary,
                                          size: 24,
                                        )
                                      else
                                        Icon(
                                          Icons.circle_outlined,
                                          color: colorScheme.onSurfaceVariant,
                                          size: 24,
                                        ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          env.name,
                                          style: theme.textTheme.bodyLarge?.copyWith(
                                            color: isSelected
                                                ? colorScheme.onPrimaryContainer
                                                : colorScheme.onSurface,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (choice != null) {
      decorationProvider.selectEnvironment(choice, choice == -1);

      // Save environment selection
      if (choice != -1 && choice < decorationProvider.userEnvironments.length) {
        final environmentId = decorationProvider.userEnvironments[choice].id;
        await decorationProvider.saveEnvironmentSelection(
          widget.dragonId,
          environmentId,
        );
      } else {
        await decorationProvider.saveEnvironmentSelection(widget.dragonId, "");
      }
    }
  }

  Positioned _buildSticker(
    StickerItem sticker,
    bool isSelected,
    ({double width, double height}) stickerEnvironmentSize,
    DragonDecorationProvider provider,
  ) {
    ThemeData theme = Theme.of(context);

    return Positioned(
      left: sticker.position.dx,
      top: sticker.position.dy,
      child: GestureDetector(
        onTap: () {
          // Only select the sticker, don't toggle
          provider.selectSticker(sticker.id);
        },
        onLongPress: () => _removeSticker(sticker.id, provider),
        child: Stack(
          children: [
            GestureDetector(
              onPanUpdate: (details) {
                if (isSelected) {
                  final newPosition = Offset(
                    sticker.position.dx + details.delta.dx,
                    sticker.position.dy + details.delta.dy,
                  );
                  provider.updateStickerPosition(
                    stickerId: sticker.id,
                    newPosition: newPosition,
                    containerSize: Size(
                      stickerEnvironmentSize.width,
                      stickerEnvironmentSize.height,
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        isSelected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: Image.network(
                  sticker.imageUrl,
                  width: sticker.size,
                  height: sticker.size,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            if (isSelected) ...[
              // Resize handle (bottom-right)
              Positioned(
                right: -8,
                bottom: -8,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    // Calculate new size based on drag distance
                    final newSize = sticker.size + details.delta.dx;
                    provider.updateStickerSize(sticker.id, newSize);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.open_with,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ),
              // Layer toggle button (top-left)
              Positioned(
                left: -8,
                top: -8,
                child: GestureDetector(
                  onTap: () {
                    provider.toggleStickerLayer(sticker.id);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      sticker.isBehindDragon
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _removeSticker(String id, DragonDecorationProvider provider) {
    provider.removeSticker(id);
  }

  void _clearAllStickers() {
    final provider = Provider.of<DragonDecorationProvider>(
      context,
      listen: false,
    );
    provider.clearAllStickers();
  }

  void _handleStickerDrop(
    DragTargetDetails details,
    double dragonSize,
    ({double height, double width}) environmentSize,
    DragonDecorationProvider provider,
  ) {
    final data = details.data;

    // Calculate the drop position using the provider's utility method
    final dropPosition = provider.calculateDropPosition(
      screenOffset: details.offset,
      dragonSize: Size(dragonSize, dragonSize),
      environmentSize: Size(environmentSize.width, environmentSize.height),
      screenSize: MediaQuery.of(context).size,
      dragonPosition: Offset(
        (MediaQuery.of(context).size.width - environmentSize.width) / 2,
        0, // This would need to be calculated based on your layout
      ),
      stickerSize: 48.0,
    );

    // Create an Item object from the drag data
    final item = Item(
      id: data['id'].toString(),
      type: ItemType.item,
      name: data['name'],
      imageUrl: data['image'],
      cost: 0,
      // Add other required properties based on your Item model
    );

    // Add the sticker using the provider
    provider.addSticker(item: item, position: dropPosition, size: 48.0);
  }

  void _showNameDialog(DragonProvider dragonProvider) {
    final TextEditingController nameController = TextEditingController(
      text: dragonProvider.getDragonById(widget.dragonId)?.name ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change Dragon Name'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      // labelText: 'Dragon Name',
                      hintText: 'Enter Your Dragon\'s Name',
                      counterText: '${nameController.text.length}/10',
                      errorText:
                          nameController.text.length > 10
                              ? 'Name cannot be longer than 10 characters'
                              : null,
                    ),
                    autofocus: true,
                    maxLength: 10,
                    onChanged: (value) {
                      setState(() {}); // Update counter and error text
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed:
                      nameController.text.trim().isEmpty ||
                              nameController.text.length > 10
                          ? null // Disable button if name is empty or too long
                          : () async {
                            try {
                              await dragonProvider.updateDragonName(
                                widget.dragonId,
                                nameController.text,
                              );
                              if (mounted) Navigator.pop(context);
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

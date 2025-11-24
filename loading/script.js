/**
 * NutriGame - Loading/Roadmap Page Script
 */

document.addEventListener('DOMContentLoaded', () => {
    // Update last update date
    updateLastUpdateDate();

    // Calculate and update progress
    updateRoadmapProgress();

    // Add smooth scroll for anchor links
    setupSmoothScroll();

    // Add intersection observer for animations
    setupScrollAnimations();
});

/**
 * Update the last update date to today
 */
function updateLastUpdateDate() {
    const lastUpdateEl = document.getElementById('lastUpdate');
    if (lastUpdateEl) {
        const options = { day: 'numeric', month: 'long', year: 'numeric' };
        const today = new Date().toLocaleDateString('pt-BR', options);
        lastUpdateEl.textContent = today;
    }
}

/**
 * Calculate and update roadmap progress based on checked items
 */
function updateRoadmapProgress() {
    const phases = document.querySelectorAll('.phase');

    phases.forEach(phase => {
        const checklistItems = phase.querySelectorAll('.checklist-item');
        const completedItems = phase.querySelectorAll('.checklist-item.done');
        const progressFill = phase.querySelector('.progress-fill');
        const progressText = phase.querySelector('.progress-text');

        if (checklistItems.length > 0 && progressFill && progressText) {
            const percentage = Math.round((completedItems.length / checklistItems.length) * 100);
            progressFill.style.width = `${percentage}%`;
            progressText.textContent = `${percentage}% completo`;
        }
    });
}

/**
 * Setup smooth scroll for anchor links
 */
function setupSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}

/**
 * Setup intersection observer for scroll animations
 */
function setupScrollAnimations() {
    const observerOptions = {
        root: null,
        rootMargin: '0px',
        threshold: 0.1
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    // Observe feature cards
    document.querySelectorAll('.feature-card').forEach(card => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
        observer.observe(card);
    });

    // Observe phases
    document.querySelectorAll('.phase').forEach((phase, index) => {
        phase.style.opacity = '0';
        phase.style.transform = 'translateY(20px)';
        phase.style.transition = `opacity 0.5s ease ${index * 0.1}s, transform 0.5s ease ${index * 0.1}s`;
        observer.observe(phase);
    });
}

// Add visible class styles
const style = document.createElement('style');
style.textContent = `
    .feature-card.visible,
    .phase.visible {
        opacity: 1 !important;
        transform: translateY(0) !important;
    }
`;
document.head.appendChild(style);

/**
 * Roadmap data structure for future updates
 * Can be used to dynamically generate the checklist
 */
const roadmapData = {
    phase1: {
        title: 'Fase 1 - MVP',
        status: 'in-progress',
        items: [
            { text: 'Definição de escopo e requisitos', done: true },
            { text: 'Documentação técnica (PRD)', done: true },
            { text: 'Estrutura do projeto Xcode', done: true },
            { text: 'Design System (cores, tipografia, componentes)', done: true },
            { text: 'Modelos de dados (User, Squad, Mission)', done: true },
            { text: 'Services Firebase (Auth, Firestore, Storage)', done: true },
            { text: 'Configurar projeto Firebase', done: false },
            { text: 'Implementar autenticação (Apple, Google, Email)', done: false },
            { text: 'UI do Onboarding', done: false },
            { text: 'Home Dashboard com XP/Level/Streak', done: false },
            { text: 'Sistema de Missões + Câmera', done: false },
            { text: 'Ranking do Squad', done: false },
            { text: 'Perfil + Galeria de fotos', done: false },
            { text: 'Notificações Push', done: false },
            { text: 'Animações e haptic feedback', done: false },
            { text: 'Testes e QA', done: false },
            { text: 'Submit para App Store', done: false }
        ]
    },
    phase2: {
        title: 'Fase 2 - Melhorias',
        status: 'upcoming',
        items: [
            { text: 'Modo offline com sincronização', done: false },
            { text: 'Integração com Apple Health', done: false },
            { text: 'Estatísticas avançadas e gráficos', done: false },
            { text: 'Melhorias de UX baseadas em feedback', done: false }
        ]
    },
    phase3: {
        title: 'Fase 3 - Monetização',
        status: 'future',
        items: [
            { text: 'Sistema de assinaturas (In-App Purchase)', done: false },
            { text: 'Features premium para pacientes', done: false },
            { text: 'Features premium para nutricionistas', done: false },
            { text: 'Painel web para nutricionistas', done: false }
        ]
    }
};

// Export for potential future use
window.NutriGameRoadmap = {
    data: roadmapData,
    updateProgress: updateRoadmapProgress
};
